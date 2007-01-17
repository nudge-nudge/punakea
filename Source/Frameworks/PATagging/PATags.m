//
//  PATags.m
//  punakea
//
//  Created by Johannes Hoffart on 18.04.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "PATags.h"

NSString * const PATagOperation = @"PATagOperation";

NSString * const PATagsHaveChangedNotification = @"PATagsHaveChangedNotification";

@interface PATags (PrivateAPI)

- (NSMutableDictionary*)tagHash;
- (void)setTagHash:(NSMutableDictionary*)someHash;
- (NSMutableDictionary*)createTagHash;

- (void)observeTag:(PATag*)tag;
- (void)observeTags:(NSArray*)someTags;
- (void)stopObservingTag:(PATag*)tag;
- (void)stopObservingTags:(NSArray*)someTags;

- (NSString *)pathForDataFile;
- (void)loadDataFromDisk;
- (void)saveDataToDisk;

- (void)tagsHaveChanged:(NSNotification*)notification;

@end

@implementation PATags

//this is where the sharedInstance is held
static PATags *sharedInstance = nil;

#pragma mark init
//constructor - only called by sharedInstance
- (id)sharedInstanceInit {
	if (self = [super init])
	{
		[self loadDataFromDisk];
		
		tagSave = [[PATagSave alloc] init];
		
		nc = [NSNotificationCenter defaultCenter];
		
		// observe all tag changes
		[nc addObserver:self 
			   selector:@selector(tagsHaveChanged:) 
				   name:nil 
				 object:self];
		
		// save on app termination
		[nc addObserver:self 
			   selector:@selector(syncToDisk:) 
				   name:NSApplicationWillTerminateNotification 
				 object:nil];
		
		// save on app going inactive
		[nc addObserver:self
			   selector:@selector(syncToDisk:)
				   name:NSApplicationDidResignActiveNotification
				 object:nil];
		
		// load on app becoming active
		[nc addObserver:self
			   selector:@selector(syncFromDisk:)
				   name:NSApplicationDidBecomeActiveNotification
				 object:nil];	
	}
	return self;
}

#pragma mark accessors
- (PATag*)tagForName:(NSString*)tagName
{	
	return [tagHash objectForKey:[tagName lowercaseString]];
}

- (NSMutableArray*)tags
{
	return tags;
}

- (void)setTags:(NSMutableArray*)otherTags
{
	[self observeTags:otherTags];
	[otherTags retain];
	[self stopObservingTags:tags];
	[tags release];
	tags = otherTags;
	
	[self setTagHash:[self createTagHash]];
	
	NSNumber *changeOperation = [NSNumber numberWithInt:PATagResetOperation];
	NSDictionary *userInfo = [NSDictionary dictionaryWithObject:changeOperation forKey:PATagOperation];
	[nc postNotificationName:PATagsHaveChangedNotification object:self userInfo:userInfo];
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

#pragma mark additional
- (NSMutableDictionary*)createTagHash
{
	NSMutableDictionary *newHash = [NSMutableDictionary dictionary];
	
	NSEnumerator *tagEnumerator = [self objectEnumerator];
	PATag *tag;
	
	while (tag = [tagEnumerator nextObject])
	{
		[newHash setObject:tag forKey:[[tag name] lowercaseString]];
	}
	
	return newHash;
}

- (NSArray*)tagsForNames:(NSArray*)tagNames
{
	NSMutableArray *resultsTags = [NSMutableArray array];
	
	NSEnumerator *e = [tagNames objectEnumerator];
	NSString *tagName;
	
	while (tagName = [e nextObject])
	{
		PATag *tag = [self tagForName:tagName];
		
		if (tag != nil)
			[resultsTags addObject:tag];
	}
	
	return resultsTags;
}

- (PATag*)createTagForName:(NSString*)tagName
{
	PATag *resultTag = [self tagForName:tagName];
	
	if (resultTag == nil)
	{
		resultTag = [[PASimpleTag alloc] initWithName:tagName];
		[self addTag:resultTag];
		[resultTag autorelease];
	}
	
	return resultTag;
}

- (void)addTag:(PATag*)aTag
{
	[self observeTag:aTag];
	[tags addObject:aTag];
	
	// update hash
	[tagHash setObject:aTag forKey:[[aTag name] lowercaseString]];
	
	NSNumber *changeOperation = [NSNumber numberWithInt:PATagAddOperation];
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:changeOperation,aTag,nil] 
														 forKeys:[NSArray arrayWithObjects:PATagOperation,@"tag",nil]];
	[nc postNotificationName:PATagsHaveChangedNotification object:self userInfo:userInfo];
}

- (void)removeTag:(PATag*)aTag
{
	[self stopObservingTag:aTag];
	
	NSNumber *changeOperation = [NSNumber numberWithInt:PATagRemoveOperation];
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:changeOperation,aTag,nil] 
														 forKeys:[NSArray arrayWithObjects:PATagOperation,@"tag",nil]];
	[nc postNotificationName:PATagsHaveChangedNotification object:self userInfo:userInfo];
	
	// remove from HD
	[aTag remove];
	
	// update hash
	[tagHash removeObjectForKey:[[aTag name] lowercaseString]];
	
	// remove from collection
	[tags removeObject:aTag];
}

- (NSEnumerator*)objectEnumerator
{
	return [tags objectEnumerator];
}

- (int)count
{
	return [tags count];
}

- (PATag*)tagAtIndex:(unsigned int)idx
{
	return [tags objectAtIndex:idx];
}

- (void)sortUsingDescriptors:(NSArray *)sortDescriptors
{
	[tags sortUsingDescriptors:sortDescriptors];
}

- (PATag*)currentBestTag
{
	PATag *bestTag = nil;
	float currentBestRating = 0.0;
	
	NSEnumerator *e = [self objectEnumerator];
	PATag *tag;
	
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

- (void)validateKeyword:(NSString*)keyword
{
	if (!keyword ||
		![keyword hasPrefix:@"@"] ||
		[keyword length] == 0 ||
		![self tagForName:[keyword substringFromIndex:1]])
	{
		NSException *e = [NSException exceptionWithName:@"InvalidKeywordException"
												 reason:@"user fiddled with comment"
											   userInfo:nil];
		@throw e;
	}
}

#pragma mark events
- (void)tagsHaveChanged:(NSNotification*)notification
{
	NSDictionary *userInfo = [notification userInfo];
	PATagChangeOperation tagOperation = [[userInfo objectForKey:PATagOperation] intValue];
	
	// ignore use count and increments ... will be saved on app termination
	if (tagOperation != PATagUseIncrementOperation
		&& tagOperation != PATagClickIncrementOperation)
	{
		[self saveDataToDisk];
	}
}

- (void)syncToDisk:(NSNotification*)notification
{
	[self saveDataToDisk];
}

- (void)syncFromDisk:(NSNotification*)notification
{
	[self loadDataFromDisk];
}


#pragma mark tag observing
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	NSNumber *changeOperation;
	
	if ([keyPath isEqualTo:@"name"])
	{
		changeOperation = [NSNumber numberWithInt:PATagNameChangeOperation];
	}
	else if ([keyPath isEqualTo:@"lastUsed"])
	{
		changeOperation = [NSNumber numberWithInt:PATagUseIncrementOperation];
	}
	else if ([keyPath isEqualTo:@"lastClicked"])
	{
		changeOperation = [NSNumber numberWithInt:PATagClickIncrementOperation];
	}
	
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:changeOperation,object,nil] 
														 forKeys:[NSArray arrayWithObjects:PATagOperation,@"tag",nil]];
	[nc postNotificationName:PATagsHaveChangedNotification object:self userInfo:userInfo];
}

- (void)observeTag:(PATag*)tag
{
	[tag addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionOld context:NULL];
	[tag addObserver:self forKeyPath:@"lastUsed" options:NSKeyValueObservingOptionOld context:NULL];
	[tag addObserver:self forKeyPath:@"lastClicked" options:NSKeyValueObservingOptionOld context:NULL];
}	

- (void)observeTags:(NSArray*)someTags
{
	NSEnumerator *e = [someTags objectEnumerator];
	PATag *tag;
	
	while (tag = [e nextObject])
	{
		[self observeTag:tag];
	}
}

- (void)stopObservingTag:(PATag*)tag
{
	[tag removeObserver:self forKeyPath:@"name"];
	[tag removeObserver:self forKeyPath:@"lastUsed"];
	[tag removeObserver:self forKeyPath:@"lastClicked"];
}

- (void)stopObservingTags:(NSArray*)someTags
{
	NSEnumerator *e = [someTags objectEnumerator];
	PATag *tag;
	
	while (tag = [e nextObject])
	{
		[self stopObservingTag:tag];
	}
}

- (NSString*)description
{
	return [tags description];
}

#pragma mark loading and saving tags
- (NSString *)pathForDataFile 
{ 
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *folder = @"~/Library/Application Support/Punakea/"; 
	folder = [folder stringByExpandingTildeInPath]; 
	
	if ([fileManager fileExistsAtPath: folder] == NO) 
		[fileManager createDirectoryAtPath: folder attributes: nil];
	
	NSString *fileName = @"tags.plist"; 
	return [folder stringByAppendingPathComponent: fileName]; 
}

- (void)saveDataToDisk 
{	
	NSLog(@"saving tags");
	
	NSString *path  = [self pathForDataFile];
	NSMutableDictionary *rootObject = [NSMutableDictionary dictionary];
	[rootObject setValue:[self tags] forKey:@"tags"];
	
	NSMutableData *data = [NSMutableData data];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver setOutputFormat:NSPropertyListXMLFormat_v1_0];
	[archiver encodeObject:rootObject];
	[archiver finishEncoding];
	[data writeToFile:path atomically:YES];
	[archiver release];
}

- (void)loadDataFromDisk 
{
	NSLog(@"loading tags");
	
	NSString *path = [self pathForDataFile];
	NSMutableData *data = [NSData dataWithContentsOfFile:path];
	
	if (data)
	{
		NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
		NSMutableDictionary *rootObject = [unarchiver decodeObject];
		[unarchiver finishDecoding];
		[unarchiver release];
		
		NSMutableArray *loadedTags = [rootObject valueForKey:@"tags"];
		
		if ([loadedTags count] > 0)
		{
			[self setTags:loadedTags];
		}
	}
	else
	{
		// on first startup there will be no data, create empty mutable array
		[self setTags:[NSMutableArray array]];
	}
}	

#pragma mark singleton stuff
- (void)dealloc {
	[tags release];
	[super dealloc];
}

+ (PATags*)sharedTags {
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

- (unsigned)retainCount {
    return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

@end
