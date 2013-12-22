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

#import "NNTagging.h"

#import "NNTags.h"

#import "lcl.h"

@interface NNTagging (PrivateAPI)

- (void)postProgressForStart:(double)start 
					 Current:(NSInteger)current 
						 Max:(NSInteger)max 
					  factor:(double)factor;

- (void)loadTagRules;

@end;

@implementation NNTagging

//this is where the sharedInstance is held
static NNTagging *sharedInstance = nil;

//constructor - only called by sharedInstance
- (id)sharedInstanceInit {
	if (self = [super init])
	{
//		// rules will be loaded asynchronously
//		opQueue = [[NSOperationQueue alloc] init];
//		tagRules = [[NSArray alloc] init];
//		[self loadTagRules];
	}
	return self;
}

- (NSArray*)taggedObjectsForTag:(NNTag*)tag
{
	return [self taggedObjectsForTags:[NSArray arrayWithObject:tag]];
}

- (NSArray*)taggedObjectsForTags:(NSArray*)tags
{
	NNQuery *query = [[NNQuery alloc] init];	
	
	NNSelectedTags *selectedTags = [[NNSelectedTags alloc] initWithTags:tags];
	[query setTags:selectedTags];
	[selectedTags release];
	
	NSArray *results = [query executeSynchronousQuery];
		
	[query release];
	
	return results;
}

- (NSArray*)allTaggedObjects
{
	NNTagToFileWriter *tagToFileWriter = [[NNTagStoreManager defaultManager] tagToFileWriter];
	NSArray *objects = [tagToFileWriter allTaggedObjects];
	return objects;
}

- (NSArray*)relatedTagsForTags:(NSArray*)tags
{
	NSArray *taggedObjects = [self taggedObjectsForTags:tags];
	
	NSMutableSet *relatedTags = [NSMutableSet set];
	
	for (NNTaggableObject *taggedObject in taggedObjects) {
		[relatedTags addObjectsFromArray:[[taggedObject tags] allObjects]];
	}
	
	return [relatedTags allObjects];
}

- (void)cleanTagsFolder
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; // Might be called in a background thread by BusyWindowController
    
	NSFileManager *fm = [NSFileManager defaultManager];
	
	NSArray *contents = [fm directoryContentsAtPath:[[NNTagStoreManager defaultManager] tagsFolder]];
	
	NSError *err;
	NSDictionary *writableAttributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithLong:448]
																   forKey:NSFilePosixPermissions];
	
	[fm setAttributes:writableAttributes
		 ofItemAtPath:[[NNTagStoreManager defaultManager] tagsFolder]
				error:&err];
	
	for (NSString *content in contents)
	{		
		// remove if folder is a tag folder
		if ([[NNTags sharedTags] tagForName:content] != nil)
		{
			content = [[[NNTagStoreManager defaultManager] tagsFolder] stringByAppendingPathComponent:content];

			BOOL success = [fm removeFileAtPath:content handler:nil];
			
			if (!success)
			{
				lcl_log(lcl_cnntagging,lcl_vError,@"Error cleaning tag folder %@",content);
			}
		}
	}
	
	// post notification to let progress know cleaning is done
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setObject:[NSNumber numberWithDouble:1.0] forKey:@"doubleValue"];
	[dict setObject:[NSNumber numberWithDouble:1.0] forKey:@"maxValue"];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:NNProgressDidUpdateNotification
														object:dict];
    
    [pool release];
}

- (void)removeTagsFolder
{
	[[NSFileManager defaultManager] removeFileAtPath:[[NNTagStoreManager defaultManager] tagsFolder] handler:NULL];
	
	// post notification to let progress know removing is done
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setObject:[NSNumber numberWithDouble:1.0] forKey:@"doubleValue"];
	[dict setObject:[NSNumber numberWithDouble:1.0] forKey:@"maxValue"];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:NNProgressDidUpdateNotification
														object:dict];
}

- (void)createDirectoryStructure
{
	[self createDirectoryStructureWithPrecedingCleanup:NO];
}

- (void)createDirectoryStructureWithPrecedingCleanup:(BOOL)cleanup
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; // Might be called in a background thread by BusyWindowController
    
	// make sure tags folder exists
	NSString *tagsFolder = [[[NNTagStoreManager defaultManager] tagsFolder] stringByStandardizingPath];
	
	BOOL isDirectory;
	
	BOOL success;
	NSError *error;
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:tagsFolder isDirectory:&isDirectory])
	{
		if (!isDirectory)
		{
			lcl_log(lcl_cnntagging,lcl_vError,@"Error creating tags folder at '%@', should be a directory",tagsFolder);
		}
	}
	else
	{
		success = [[NSFileManager defaultManager] createDirectoryAtPath:tagsFolder withIntermediateDirectories:YES attributes:nil error:&error];
		
		// make sure the directory is writable before setting the icon
		NSDictionary *writableAttributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithLong:448]
																	   forKey:NSFilePosixPermissions];
		success = success && [[NSFileManager defaultManager] setAttributes:writableAttributes
															  ofItemAtPath:tagsFolder
																	 error:nil];
		
		if (!success) {
			lcl_log(lcl_cnntagging,lcl_vError,@"Error creating tags folder at '%@' (%@)",tagsFolder, [error localizedDescription]);			
		}
	}
	
	// make sure the tagsFolder is empty if needed
	if (cleanup)
	{
		[self cleanTagsFolder];
	}
	
	// create new structure
	NSArray *taggedObjects = [[NNTagging tagging] allTaggedObjects];
	
	NSInteger current = 0;
	NSInteger count = [taggedObjects count];
	
	NNTagDirectoryWriter *tagDirectoryWriter = [[NNTagStoreManager defaultManager] tagDirectoryWriter];
	
	// post initial progress notification
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
	[userInfo setObject:[NSNumber numberWithDouble:(double)current] forKey:@"currentProgress"];
	[userInfo setObject:[NSNumber numberWithDouble:(double)count] forKey:@"maximumProgress"];	
	[nc postNotificationName:NNProgressDidUpdateNotification
					  object:self 
					userInfo:userInfo];	
		
	for (NNTaggableObject *object in taggedObjects)
	{
		[tagDirectoryWriter createDirectoryStructureForTaggableObject:object withOldTags:[NSMutableArray array]];
		
		// post progress notification
		current++;
		[userInfo setObject:[NSNumber numberWithDouble:(double)current] forKey:@"currentProgress"];
		[nc postNotificationName:NNProgressDidUpdateNotification 
						  object:self 
						userInfo:userInfo];
	}
    
    [pool release];
}

- (void)cleanTagDB
{	
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; // Might be called in a background thread by BusyWindowController
    
	// post initial progress notification
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
	[userInfo setObject:[NSNumber numberWithDouble:0.0] forKey:@"currentProgress"];
	[userInfo setObject:[NSNumber numberWithDouble:1.0] forKey:@"maximumProgress"];	
	[nc postNotificationName:NNProgressDidUpdateNotification
					  object:self 
					userInfo:userInfo];	
	
	// dictionary to hold tags and new useCount
	NSMutableDictionary *tagDict = [NSMutableDictionary dictionary];
	
	// for every tag in the db, set the useCount to 0
	NNTags *sharedTags = [NNTags sharedTags];
	
	for (NNTag* tag in [sharedTags tags])
	{
		[tagDict setObject:[NSNumber numberWithUnsignedLong:0] forKey:[tag name]];
	}
	
	// post progress notification
	[userInfo setObject:[NSNumber numberWithDouble:0.05] forKey:@"currentProgress"];
	[nc postNotificationName:NNProgressDidUpdateNotification 
					  object:self 
					userInfo:userInfo];
	
	// now get all tagged files
	NSArray *taggedObjects = [[NNTagging tagging] allTaggedObjects];
	
	// post progress notification
	[userInfo setObject:[NSNumber numberWithDouble:0.1] forKey:@"currentProgress"];
	[nc postNotificationName:NNProgressDidUpdateNotification 
					  object:self 
					userInfo:userInfo];
		
	// for each tag on an object, increment the tags use count
	for (NNTaggableObject* obj in taggedObjects)
	{
		for (NNTag* tag in [obj tags])
		{
			NSUInteger count = [[tagDict objectForKey:[tag name]] unsignedLongValue];
			count++;
			[tagDict setObject:[NSNumber numberWithUnsignedLong:count] forKey:[tag name]];
		}
	}
	
	// post progress notification
	[userInfo setObject:[NSNumber numberWithDouble:0.2] forKey:@"currentProgress"];
	[nc postNotificationName:NNProgressDidUpdateNotification 
					  object:self 
					userInfo:userInfo];
	
	NSMutableArray *tagsToDelete = [NSMutableArray array];
	
	NSInteger currentCount = 0;
    NSArray *allTags = [NSArray arrayWithArray:[sharedTags tags]];
	NSInteger tagCount = [allTags count];
	
	// now set the useCount to the real db
	// and delete all tags with their useCount still 0
	for (NNTag *tag in allTags)
	{
		// work on the tag						
		NSUInteger useCount = [[tagDict objectForKey:[tag name]] unsignedLongValue];
		
		if (useCount == 0)
		{
			[tagsToDelete addObject:tag];
		}
		else
		{
			[tag setUseCount:useCount];
		}
		
		// progress update
		currentCount++;
		[self postProgressForStart:0.2 Current:currentCount Max:tagCount factor:0.4];
	}
	
	// post progress notification
	[userInfo setObject:[NSNumber numberWithDouble:0.9] forKey:@"currentProgress"];
	[nc postNotificationName:NNProgressDidUpdateNotification 
					  object:self 
					userInfo:userInfo];
	
	for (NNTag* tag in tagsToDelete)
		[[NNTags sharedTags] removeTag:tag];
	
	// post progress notification
	[userInfo setObject:[NSNumber numberWithDouble:1.0] forKey:@"currentProgress"];
	[nc postNotificationName:NNProgressDidUpdateNotification 
					  object:self 
					userInfo:userInfo];
    
    [pool release];
}

- (void)postProgressForStart:(double)start 
					 Current:(NSInteger)current 
						 Max:(NSInteger)max 
					  factor:(double)factor
{
	double progress = (double) current / (double) max;
	double adjustedProgress = ((double) start) + (progress * factor);
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
	[userInfo setObject:[NSNumber numberWithDouble:1.0] forKey:@"maximumProgress"];		
	[userInfo setObject:[NSNumber numberWithDouble:adjustedProgress] forKey:@"currentProgress"];
	[nc postNotificationName:NNProgressDidUpdateNotification 
					  object:self 
					userInfo:userInfo];
}

- (NSArray*)tagNamesForTags:(NSArray*)tags
{
	NSMutableArray *tagNames = [NSMutableArray arrayWithCapacity:[tags count]];
	
	for (NNTag *tag in tags)
	{
		[tagNames addObject:[tag name]];
	}
	
	return tagNames;
}

- (NSArray*)tagsForTagnames:(NSArray*)tagnames
{
	NSArray *tags = [[NNTags sharedTags] tagsForNames:tagnames 
									  creationOptions:NNTagsCreationOptionNone];
	
	return tags;
}


#pragma mark tag rules
- (NSArray*)associatedTagsForTags:(NSArray*)tags
{
	NSArray *tagnames = [self tagNamesForTags:tags];
	NSArray *associatedTagnames = [tagRules associatedTagsForTags:tagnames];
	NSArray *associatedTags = [self tagsForTagnames:associatedTagnames];
	
	return associatedTags;
}

- (void)loadTagRules
{
	NNAssociationRuleDiscoveryOperation *op = [[NNAssociationRuleDiscoveryOperation alloc] init];
	[opQueue addOperation:op];
	[op release];
}	

- (void)updateTagRules:(NSArray*)rules
{
	lcl_log(lcl_cnntagging, lcl_vInfo, @"New association rules mined");
		
	[tagRules release];
	tagRules = [[NNAssociationRules alloc] initWithRules:rules];
}
	
#pragma mark singleton stuff
+ (NNTagging*)tagging {
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
