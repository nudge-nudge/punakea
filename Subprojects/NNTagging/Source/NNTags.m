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

#import "NNTags.h"

#import "NNTagBackup.h"
#import "NNTagging.h"

#import "lcl.h"

NSString * const NNTagOperation = @"NNTagOperation";

NSString * const NNTagRemoveOperation = @"NNTagRemoveOperation";

NSString * const NNTagAddOperation = @"NNTagAddOperation";

NSString * const NNTagResetOperation = @"NNTagResetOperation";

NSString * const NNTagNameChangeOperation = @"NNTagNameChangeOperation";

NSString * const NNTagUseChangeOperation = @"NNTagUseChangeOperation";

NSString * const NNTagClickIncrementOperation = @"NNTagClickIncrementOperation";

NSString * const NNTagsHaveChangedNotification = @"NNTagsHaveChangedNotification";

@interface NNTags (PrivateAPI)

/**
 this is private and should not be used
 unless you really know what you are doing!
 at the moment it is only used on app startup and
 when the app needs to sync to the tag db
 */
- (void)setTags:(NSMutableArray*)otherTags;

- (void)setup;

- (void)loadUserDefaults;

- (NSMutableDictionary*)tagHash;
- (void)setTagHash:(NSMutableDictionary*)someHash;
- (NSMutableDictionary*)createTagHash;
- (NSString*)hashKeyForName:(NSString*)tagName;

- (void)addTag:(NNTag*)aTag;

- (void)observeTag:(NNTag*)tag;
- (void)observeTags:(NSArray*)someTags;
- (void)stopObservingTag:(NNTag*)tag;
- (void)stopObservingTags:(NSArray*)someTags;

- (void)loadDataFromDisk;
- (void)saveDataToDisk;

- (void)tagsHaveChanged:(NSNotification*)notification;

- (void)checkTagsConsistency;
- (void)checkForDuplicates;

@end

@implementation NNTags

//this is where the sharedInstance is held
static NNTags *sharedInstance = nil;

#pragma mark init
//constructor - only called by sharedInstance
- (id)sharedInstanceInit {
	if (self = [super init])
	{
		lcl_configure_by_name("lib/*", lcl_vTrace);
		
		// load tags from db
		[self loadDataFromDisk];
		
		// update files if needed
		NNCompatbilityChecker *checker = [[NNCompatbilityChecker alloc] init];
		[checker update];
		[checker release];
		
		nc = [NSNotificationCenter defaultCenter];
		
		// observe all tag changes
		[nc addObserver:self 
			   selector:@selector(tagsHaveChanged:) 
				   name:NNTagsHaveChangedNotification 
				 object:self];
			
		// starts background thread if tag changes need to be written
		tagSave = [[NNTagSave alloc] init];

		// set the default tag click count weight
		tagClickCountWeight = 0.0;
		
		// check if tag db is consistent
		[self checkTagsConsistency];
		
		// call nntagging once to initialize it
		[NNTagging tagging];
				
		lcl_log(lcl_cnntagging, lcl_vInfo, @"NNTagging loaded");
	}
	
	return self;
}

#pragma mark accessors
- (NSMutableArray*)tags
{
	return tags;
}

- (void)setTags:(NSMutableArray*)otherTags
{
	@synchronized (self)
	{
		[self stopObservingTags:tags];
		
		[otherTags retain];
		[tags release];
		tags = otherTags;
		
		[self observeTags:tags];
		
		[self setTagHash:[self createTagHash]];
		
		NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NNTagResetOperation forKey:NNTagOperation];
		[nc postNotificationName:NNTagsHaveChangedNotification object:self userInfo:userInfo];
	}
}

- (NSMutableDictionary*)tagHash
{
	return tagHash;
}

- (void)setTagHash:(NSMutableDictionary*)someHash
{
	[someHash retain];
	[tagHash release];
	tagHash = someHash;
}

- (CGFloat)tagClickCountWeight
{
	return tagClickCountWeight;
}

- (void)setTagClickCountWeight:(CGFloat)weight
{
	tagClickCountWeight = weight;
}

#pragma mark additional
- (NSMutableDictionary*)createTagHash
{
	NSMutableDictionary *newHash = [NSMutableDictionary dictionary];
	
	NSEnumerator *tagEnumerator = [self objectEnumerator];
	NNTag *tag;
	
	while (tag = [tagEnumerator nextObject])
	{
		NSString *lowerCaseTagName = [[tag name] lowercaseString];
		[newHash setObject:tag forKey:lowerCaseTagName];
	}
	
	return newHash;
}

- (NNTag*)tagForName:(NSString*)tagName
{	
	return [self tagForName:tagName creationOptions:NNTagsCreationOptionNone];
}

- (NNTag*)tagForName:(NSString*)tagName creationOptions:(NNTagsCreationOptions)options
{
	NNTag *resultTag = [tagHash objectForKey:[self hashKeyForName:tagName]];
			
	if (resultTag == nil && options != NNTagsCreationOptionNone)
	{
		switch (options)
		{
			case NNTagsCreationOptionFull:		
				resultTag = [[NNSimpleTag alloc] initWithName:tagName];
				// add tag to collection
				[self addTag:resultTag];
				[resultTag autorelease];
				break;
				
			case NNTagsCreationOptionTemp:
				resultTag = [[NNTempTag alloc] initWithName:tagName];
				[resultTag autorelease];
				break;
		}				
	}
	
	return resultTag;
}

- (NSArray*)tagsForNames:(NSArray*)tagNames
{
	return [self tagsForNames:tagNames creationOptions:NNTagsCreationOptionNone];
}

- (NSArray*)tagsForNames:(NSArray*)tagNames creationOptions:(NNTagsCreationOptions)options
{
	NSMutableArray *resultTags = [NSMutableArray array];
	
	NSEnumerator *e = [tagNames objectEnumerator];
	NSString *tagName;
	
	while (tagName = [e nextObject])
	{
		NNTag *tag = [self tagForName:tagName creationOptions:options];
		
		if (tag != nil)
			[resultTags addObject:tag];
	}
	
	return resultTags;
}

/**
 This method alters the string somewhat to generate a fitting hashKey
 */
- (NSString*)hashKeyForName:(NSString*)tagName
{
	NSString *lowercaseDecomposedTagName = [[tagName decomposedStringWithCanonicalMapping] lowercaseString];
	
	// ";" and ":" is not allowed in tag names at the moment
	// replace by _
	NSMutableString *cleanedName = [lowercaseDecomposedTagName mutableCopy];
	[cleanedName replaceOccurrencesOfString:@";"
								 withString:@"_"
									options:0
									  range:NSMakeRange(0,[cleanedName length])];
	[cleanedName replaceOccurrencesOfString:@":"
								 withString:@"_"
									options:0
									  range:NSMakeRange(0,[cleanedName length])];
	
	return [cleanedName autorelease];
}

- (void)addTag:(NNTag*)aTag
{
	@synchronized (self)
	{
		[self observeTag:aTag];
		[tags addObject:aTag];

		// update hash
		[tagHash setObject:aTag forKey:[self hashKeyForName:[aTag name]]];
		
		NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:NNTagAddOperation,aTag,nil] 
															 forKeys:[NSArray arrayWithObjects:NNTagOperation,@"tag",nil]];
		[nc postNotificationName:NNTagsHaveChangedNotification object:self userInfo:userInfo];
	}
}

- (void)removeTag:(NNTag*)aTag
{
	@synchronized (self)
	{
		[self stopObservingTag:aTag];
		
		NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:NNTagRemoveOperation,aTag,nil] 
															 forKeys:[NSArray arrayWithObjects:NNTagOperation,@"tag",nil]];
		
		// remove from tagged objects
		[aTag remove];
		
		// update hash
		[tagHash removeObjectForKey:[self hashKeyForName:[aTag name]]];
		
		// remove from collection
		[tags removeObject:aTag];
		
		[nc postNotificationName:NNTagsHaveChangedNotification object:self userInfo:userInfo];
	}
}

- (NSEnumerator*)objectEnumerator
{
	return [tags objectEnumerator];
}

- (NSInteger)count
{
	return [tags count];
}

- (NNTag*)tagAtIndex:(NSUInteger)idx
{
	return [tags objectAtIndex:idx];
}

- (void)sortUsingDescriptors:(NSArray *)sortDescriptors
{
	[tags sortUsingDescriptors:sortDescriptors];
}

- (NNTag*)currentBestTag
{
	NNTag *bestTag = nil;
	CGFloat currentBestRating = 0.0;
	
	NSEnumerator *e = [self objectEnumerator];
	NNTag *tag;
	
	while (tag = [e nextObject])
	{
		if ([tag absoluteRating] > currentBestRating)
		{
			currentBestRating = [tag absoluteRating];
			bestTag = tag;
		}
	}
	
	return bestTag;
}

- (NSArray *)tagsSortedByRating:(NSSet *)someTags ascending:(bool)ascending
{
	NSArray *sorted = [NSArray arrayWithArray:[someTags allObjects]];
	
	NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:ascending selector:@selector(compareByRating:)];
	
	sorted = [sorted sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];

	return sorted;
}

- (void)validateKeyword:(NSString*)keyword
{
	if (!keyword ||
		![keyword hasPrefix:@"@"] ||
		([keyword length] < 2) )
	{
		NSException *e = [NSException exceptionWithName:@"InvalidKeywordException"
												 reason:@"user fiddled with comment"
											   userInfo:nil];
		@throw e;
	}
}

#pragma mark events
// this method is really important, as every tag change gets posted
// here. tagsHaveChanged: takes care of updating the cache and
// the sqlite db
- (void)tagsHaveChanged:(NSNotification*)notification
{		
	// make sure all objects are available
	NSDictionary *userInfo = [notification userInfo];
	
	if (userInfo == nil)
	{
		lcl_log(lcl_cnntagging, lcl_vError, @"UserfInfo unavailable");
		return;
	}

	// more checking
	NSString *tagOperation = [userInfo objectForKey:NNTagOperation];
		
	if (tagOperation == nil)
	{
		lcl_log(lcl_cnntagging, lcl_vError, @"tagOperation missing");
		return;
	}
	
	// all is there - do the work
	if ([tagOperation isEqualToString:NNTagResetOperation])
	{
		// all tags where updated, don't do anything as the
		// tags have been synced from the database already
		return;
	}
	
	// check if tag exists
	NNTag *tag = [userInfo objectForKey:@"tag"];
	if (tag == nil)
	{
		lcl_log(lcl_cnntagging, lcl_vError, @"tag missing");
		return;
	}
	
	if ([tagOperation isEqualToString:NNTagUseChangeOperation])
	{		
		// test if use count is zero -> remove tag
		if ([tag useCount] == 0)
		{
			// check if the use count is in sync with the real situation
			NSArray *files = [[NNTagging tagging] taggedObjectsForTag:tag];
			
			if ([files count] > 1)
			{
				// there are other files that are still tagged
				// set use count to real value
				NSInteger realUseCount = [files count] - 1;
				[tag setUseCount:realUseCount];
			}
			else
			{
				// this will post a NNTagRemoveOperation notification,
				// which takes care of removing tag from db
				[self removeTag:tag];
			}
		}
		else
		{		
			[tag writeToTagDatabase];
		}
	}
	else if ([tagOperation isEqualToString:NNTagNameChangeOperation])
	{
		// recreate tag hash
		[self setTagHash:[self createTagHash]];
		[tag writeToTagDatabase];
	}
	else if ([tagOperation isEqualToString:NNTagRemoveOperation])
	{
		[tag removeFromTagDatabase];
	}
	else
	{
		// otherwise simply write update to tag db
		[tag writeToTagDatabase];
	}
}

#pragma mark tag observing
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	NSString *changeOperation;
	
	if ([keyPath isEqualTo:@"name"])
	{
		changeOperation = NNTagNameChangeOperation;
	}
	else if ([keyPath isEqualTo:@"useCount"])
	{
		changeOperation = NNTagUseChangeOperation;
	}
	else if ([keyPath isEqualTo:@"clickCount"])
	{
		changeOperation = NNTagClickIncrementOperation;
	}
	
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:changeOperation,object,nil] 
														 forKeys:[NSArray arrayWithObjects:NNTagOperation,@"tag",nil]];
	[nc postNotificationName:NNTagsHaveChangedNotification object:self userInfo:userInfo];
}

- (void)observeTag:(NNTag*)tag
{
	[tag addObserver:self forKeyPath:@"name" options:0 context:NULL];
	[tag addObserver:self forKeyPath:@"useCount" options:0 context:NULL];
	[tag addObserver:self forKeyPath:@"clickCount" options:0 context:NULL];
}	

- (void)observeTags:(NSArray*)someTags
{
	NSEnumerator *e = [someTags objectEnumerator];
	NNTag *tag;
	
	while (tag = [e nextObject])
	{
		[self observeTag:tag];
	}
}

- (void)stopObservingTag:(NNTag*)tag
{
	@try
	{
		[tag removeObserver:self forKeyPath:@"name"];
		[tag removeObserver:self forKeyPath:@"useCount"];
		[tag removeObserver:self forKeyPath:@"clickCount"];
	}
	@catch (NSException *e) 
	{
		lcl_log(lcl_cnntagging,lcl_vWarning,@"Could not remove observer: %@ - %@",[e name],[e reason]);
	}
}

- (void)stopObservingTags:(NSArray*)someTags
{
	NSEnumerator *e = [someTags objectEnumerator];
	NNTag *tag;
	
	while (tag = [e nextObject])
	{
		[self stopObservingTag:tag];
	}
}

- (NSString*)description
{
	return [tags description];
}

#pragma mark loading and saving
- (void)loadDataFromDisk 
{
	NSMutableArray *loadedTags = [[NNTagStoreManager defaultManager] tagsFromSQLdb];		
	[self setTags:loadedTags];
}	

- (void)saveDataToDisk
{
	// tell tagStore to clean the database and write all tags anew
	[[NNTagStoreManager defaultManager] setSQLdbToTags:[self tags]];
}

// public method to sync db
- (void)syncFromDB
{
	[self loadDataFromDisk];
}

#pragma mark consistency checking
- (void)checkTagsConsistency
{
	// nothing to do at the moment
}

#pragma mark singleton stuff
- (void)dealloc {
	[tags release];
	[super dealloc];
}

+ (NNTags*)sharedTags {
	@synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[self alloc] sharedInstanceInit];
        }
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
        }
    }
    return sharedInstance;
}

- (id)retain {
    return self;
}

- (NSUInteger)retainCount {
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

@end
