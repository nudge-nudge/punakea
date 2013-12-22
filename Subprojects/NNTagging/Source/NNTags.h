// Copyright (c) 2006-2013 nudge:nudge (Johannes Hoffart & Daniel Bär). All rights reserved.
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

/** @file */

/**

\mainpage NNTagging Framework
 
\section basics The Basics

Follow this guide to add the nudge:nudge Tagging Framework to your application.

\subsection linkFramework Link the framework
Drag NNTagging.framework into the Linked Frameworks folder of your Xcode project and make sure to check the "Copy items into destination group's folder" box in the resulting sheet.

\subsection deployFramework Deploy the framework
<ul>
<li>Create a new Copy Files build phase (Project > New Build Phase) and select Frameworks for destination.</li>
<li>Switch to the Project page (cmd-0), find your target in the files list, and reveal its contents by clicking the disclosure triangle next to it.</li>
<li>Drag NNTagging.framework from the Linked Frameworks folder to the new Copy Files phase.</li>
</ul>

\section nextsteps Next Steps

\subsection newTag Create new tag

<pre>
NNTag *newTag = [[NNTags sharedTags] tagForName:@"newTagName" 
                                creationOptions:NNTagsCreationOptionFull];
</pre>

New tags are automatically added to the tag database and are saved to the disk, you don't have to care about that. After the creation, tags can be accessed using

<pre>
NNTag *oldTag = [[NNTags sharedTags] tagForName:@"newTagName"];
//oldTag might be nil, if there is no such tag
</pre>

\subsection addTag Add tag to file

To add a tag to a file, use the NNFile class by initializing it from a file path given as NSString, then calling the <pre>addTag:</pre> method.
<pre>
NSString *pathToFile = @"/path/to/file";
NNFile *newFile = [NNFile fileWithPath:pathToFile];
[newFile addTag:newTag];
</pre>
The NNFile will take care of writing the spotlight comment

\subsection search Search for a tag
There are two ways to do this:

<ol>
<li>
First, you need to create a query and set the tag to search for

<pre>
NNQuery *query = [[NNQuery alloc] init];
NNSelectedTags *selectedTags = 
	[[NNSelectedTags alloc] initWithTags:[NSArray arrayWithObjects:newTag,nil]];
[query setTags:selectedTags];
</pre>

Then you should register for the NNQuery notifications and start the search

<pre>
[[NSNotificationCenter defaultCenter] addObserver:self 
    selector:\@selector(queryNote:) 
    name:NNQueryDidFinishGatheringNotification object:query];
[query startQuery];
</pre>

For other query notifications check the NNQuery API.
 
As an alternative, you could simply use
 
<pre>
NSArray *results = [query executeSynchronousQuery];
</pre>
 
which will not post any progress notifications but return the results immediately. (This has the same implications as using [tag taggedObjects] - see below!)

Once the results have been gathered, you can get to them using the following snippet.

<pre>
NSArray *results = [query results];
</pre>

The results are of the NNTaggableObject class.
</li>
<li>
This way is easier by far:

<pre>
NNTag *tag = [[NNTags sharedTags] tagForName:@"tagName"]; 
// tag may be nil, check for this in your code,
// or use tagForName:creationOptions with NNTagsCreationOptionFull
NSArray *taggableObjects = [tag taggedObjects];
</pre>
</li>
</ol>

The second way is of course easier to use, but has several disadvantages
<ul>
<li>
Search is executed synchronously in the thread calling the taggedObjects: method - this could lead to quite some
interface blocking if called from main thread.
</li>
<li>
You can not see intermediate results, as you can with NNQuery registering for the NNQueryGatheringProgressNotification.
</li>
</ul>

We hope this gave you a quick grasp of what the framework does, there are a lot more classes and more functionality, 
though, so be sure to look at the API for the appropriate classes.

*/

#import <Cocoa/Cocoa.h>
#import "NNTag.h"
#import "NNSimpleTag.h"
#import "NNTempTag.h"
#import "NNTagSave.h"
#import "NNCompatbilityChecker.h"
#import "NNTagStoreManager.h"

@class NNTagBackup;
@class NNTagging;

/**
used as key in the NNTagsHaveChangedNotification 
 @see NNTagsHaveChangedNotification
 */
extern NSString * const NNTagOperation;

/** the key used when a tag is removed from the collection */
extern NSString * const NNTagRemoveOperation;

/** the key used when a tag is added to the collection */
extern NSString * const NNTagAddOperation;

/** the key used when the collection as a whole is reset */
extern NSString * const NNTagResetOperation;

/** the key used when a tag's name is changed */
extern NSString * const NNTagNameChangeOperation;

/** the key used when a tag's use count changes */
extern NSString * const NNTagUseChangeOperation;

/** the key used when a tag is clicked */
extern NSString * const NNTagClickIncrementOperation;

/**
this is the name of the NSNotification sent by NNTags if a NNTag has been:
 <ul>
   <li>added</li>
   <li>removed</li>
   <li>renamed</li>
   <li>clicked</li>
   <li>used (assigned to/removed from a NNTaggableObject)</li>
 </ul>
 
 the Notification will contain a userInfo dict with the following keys
 <dl>
   <dt>NNTagOperation</dt><dd>will return a string corresponding to the NNTag<something>Operation keys</dd>
   <dt>@"tag"</dt><dd>if it makes sense, contains the NNTag for the ChangeOperation (every one Except NNTagResetOperation)</dd>
 </dl>
 
*/
extern NSString * const NNTagsHaveChangedNotification;

/**
NNTagsCreationOptionNone will return nil if no tag exists for tagName
NNTagsCreationOptionsFull will create a new NNSimpleTag if no tag exists
NNTagsCreationOptionTemp will create a new NNTempTag if no tag exists (which will not be added to the db)
 */
enum {
	NNTagsCreationOptionNone = 0x01,
	NNTagsCreationOptionTemp = 0x02,
	NNTagsCreationOptionFull = 0x04,
};
typedef NSUInteger NNTagsCreationOptions;

/**
contains all NNTag instances in the application. don't rely on tag order!
 posts NNTagsHaveChanged notification whenever the tags array has changed or a single tag was renamed, clicked or used.
 */
@interface NNTags : NSObject {
	/** \internal holds all tags */
	NSMutableArray *tags;
	
	/** 
		\internal
		hash tagname -> tag for quick access 
		hash uses lowercase-only strings for identifying
	*/
	NSMutableDictionary *tagHash;
	
	/**
		\internal
		takes care of writing tags on file to backup storage 
		needs to be started only, everything else is handled
		internally
	*/
	NNTagSave *tagSave;
		
	CGFloat tagClickCountWeight;
	
	NSNotificationCenter *nc;
}

/**
 Use this to access the singleton.
 */
+ (NNTags*)sharedTags;

/**
Call this to get a tag for a String - do not simply create new tags!
 @param tagName Name of the tag to return
 @return Tag with name or nil
 */
- (NNTag*)tagForName:(NSString*)tagName;

/**
Call this to get a tag for a String - control tag creation by using the NNTagCreationOptions:
 NNTagsCreationOptionNone will return nil if no tag exists for tagName
 NNTagsCreationOptionsFull will create a new NNSimpleTag if no tag exists
 NNTagsCreationOptionTemp will create a new NNTempTag if no tag exists (which will not be added to the db)
 @param tagName Name of the tag
 @param options Creation options @see NNTagsCreationOptions
 @return Tag with name or new NNSimpleTag for tagName
 */
- (NNTag*)tagForName:(NSString*)tagName creationOptions:(NNTagsCreationOptions)options;

/**
Get all tags corresponding to the names - if they exist
 @param tagNames Array of strings
 @return Tags for tagNames
 */
- (NSArray*)tagsForNames:(NSArray*)tagNames;

/**
Get all tags corresponding to the keywords in the tagNames array are returned.
 Creation options can be used like in tagForName:options:
 @param tagNames NSArray of NSStrings with tag names
 @param options Creation options
 @return Array with tags for tagNames
 */
- (NSArray*)tagsForNames:(NSArray*)tagNames creationOptions:(NNTagsCreationOptions)options;

/**
@return All currently known tags as an Array
 */
- (NSMutableArray*)tags;

/**
Removes a tag.
 @param aTag Tag to remove
 */
- (void)removeTag:(NNTag*)aTag;

/**
@return NSEnumerator for NNTags
 */
- (NSEnumerator*)objectEnumerator;

/**
@return Number of NNTags
 */
- (NSInteger)count;

/**
@return NNTag at index idx
 */
- (NNTag*)tagAtIndex:(NSUInteger)idx;

/**
Sorts the tags accordings to the descriptors.
 Use this if you want to have a temporarily sorted tag array -
 this is not very long lived ;)
@param sortDescriptors 
 */
- (void)sortUsingDescriptors:(NSArray *)sortDescriptors;

/**
@return NNTag with the best overal rating
 */
- (NNTag*)currentBestTag;

/**
@return Array of tags sorted by their overall weighting in descending order
 */
- (NSArray *)tagsSortedByRating:(NSSet *)someTags ascending:(bool)ascending;

/**
Will throw an exception for an invalid keyword.
 A keyword is invalid if it does not have @ as a prefix or consists only of the @
 @param keyword keyword to validate
  */
- (void)validateKeyword:(NSString*)keyword;

/**
 @return Weight of the tag's click count
 */
- (CGFloat)tagClickCountWeight;

/**
 @param weight Weight the click count of a tag should have in respect to the use count.
 Values are in range 0 (use count only) to 1 (click count only)
 */
- (void)setTagClickCountWeight:(CGFloat)weight;

/**
 Call this to sync NNTags to tags in sqlite DB
 */
- (void)syncFromDB;

@end