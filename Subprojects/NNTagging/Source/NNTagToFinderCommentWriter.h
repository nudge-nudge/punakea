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


#import <Cocoa/Cocoa.h>

#import "NNTagToFileWriter.h"

#import "Finder.h"

@class NNFile;

extern NSString * const TAGGER_WHITESPACE_SEPARATOR;

enum {
	NNFinderCommentSpotlightStore = 0x01,
	NNFinderCommentFinderStore = 0x02
};
typedef NSUInteger NNFinderCommentStore;

/**
 Abstract class 
 
 Provides different tag syntax for Spotlight Finder Comment and the ways
 to write it.
 */
@interface NNTagToFinderCommentWriter : NNTagToFileWriter {
	FinderApplication *finder;
}

/**
 Abstract method for template method.
 
 @param tags	Tags to create the comment for
 @return		String representation for tags in concrete syntax
 */
- (NSString*)finderTagCommentForTags:(NSArray*)tags;

/**
 Abstract method for template method.
 @param file	File to get comment for
 @return		Finder comment contents without NNTagging stuff
 */
- (NSString*)finderCommentIgnoringKeywordsForFile:(NNFile*)file;

/**
 Abstract method.
 
 @param file	File to get tags for
 @param options Influence tag creation
 @param store	Determines the backing storage to get the finder comments from
 @return		Array of NNTags on file
 */
- (NSArray*)readTagsFromFile:(NNFile*)file 
			 creationOptions:(NNTagsCreationOptions)options
					useStore:(NNFinderCommentStore)store;

/**
 Abstract method.
 
 Calls tagsInComment:creationOptions with NNTagsCreationOptionNone
 
 @param comment	Finder Comment
 @return		Tags in comment
 */
- (NSArray*)tagsInComment:(NSString*)comment;

/**
 Abstract method.
 
 Parses the passed string to get the tags.
 
 @param comment Finder Comment
 @param options Determines if tags are created
 @return		Tags in comment
 */
- (NSArray*)tagsInComment:(NSString*)comment creationOptions:(NNTagsCreationOptions)options;

/**
 Abstract method.
 
 Reads the tag names from the Finder Comment
 
 @param comment	Finder Comment
 @return NSArray of NSString with tag names
 */
- (NSArray*)keywordsForComment:(NSString*)comment;

/**
 Calls commentForFile:useStore with NNFinderCommentFinderStore
 
 Uses the finder scripting bridge to fetch the finder comment.
 Will cause hangs when using this while dragging the file from finder.
 
 @param file	File to get comment for
 @return		comment
 */
- (NSString*)commentForFile:(NNFile*)file;

/**
 Using the spotlight db to fetch the finder comment won't cause Finder to hang on drop,
 but data might be out of date.
 
 @param file file to get comment for
 @param store Determines the backing storage to get the finder comments from
 @return comment
 */
- (NSString*)commentForFile:(NNFile*)file useStore:(NNFinderCommentStore)store;

// methods for handling the prefix
/**
 @return Tag prefix as set in NNTagStoreManager
 */
- (NSString*)prefix;

/**
 @param aPrefix	Prefix to use in NNTagStoreManager
 */
- (void)setPrefix:(NSString*)aPrefix;

// accessing Finder Comments via Finder Scripting Bridge
/**
 Sets the finder comment using the scripting bridge.
 
 @param comment New comment
 @param fileURL File to set comment for
 @return		YES on success, NO otherwise
 */
- (BOOL)setComment:(NSString *)comment forURL:(NSURL *)fileURL;

@end
