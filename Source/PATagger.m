//
//  TaggerInterface.m
//  punakea
//
//  Created by Johannes Hoffart on 05.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PATagger.h"

@interface PATagger (PrivateAPI)

- (void)writeTags:(NSArray*)tags ToFile:(NSString*)path;
/**
get tags as PASimpleTag array for file at path
 this function is for Tagger-internal use only, doesn't return the "real" tag,
 only a placeholder without click and use count and stuff
 @param path file for which to get the tags
 @return array with PASimpleTags corresponding to the kMDItemKeywords on the file
 */
- (NSMutableArray*)tagsForFile:(NSString*)path;
@end

@implementation PATagger

//this is where the sharedInstance is held
static PATagger *sharedInstance = nil;

#pragma mark init
//constructor - only called by sharedInstance
- (id)sharedInstanceInit {
	self = [super init];
	if (self)
	{
		tagFactory = [[PASimpleTagFactory alloc] init];
	}
	return self;
}

#pragma mark tags and files
//write tags
- (void)addTag:(PASimpleTag*)tag ToFile:(NSString*)path {
	[self addTags:[NSArray arrayWithObject:tag] ToFile:path];
}

//adds the specified tags, doesn't overwrite - TODO check if works with PATag
- (void)addTags:(NSArray*)tags ToFile:(NSString*)path {
	NSMutableArray *resultTags = [NSMutableArray arrayWithArray:tags];
	
	//existing tags must be kept - only if there are any
	if ([[self tagsForFile:path] count] > 0) {
		NSArray *currentTags = [self tagsForFile:path];

		/* check if the file had tags which are not in the
		   tags to be added - need to keep them */
		NSEnumerator *e = [currentTags objectEnumerator];
		id tag;
		
		while ( (tag = [e nextObject]) ) 
		{
			if (![resultTags containsObject:tag]) 
			{
				[resultTags addObject:tag];
				
				// increment use count here, that way the other classes
				// don't have to care
				[tag incrementUseCount];
			}
		}
	}
	
	//write the tags to kMDItemKeywords - new and existing ones
	[self writeTags:resultTags ToFile:path];
}

- (void)addTag:(PASimpleTag*)tag ToFiles:(NSArray*)paths
{
	NSEnumerator *e = [paths objectEnumerator];
	NSString *path;
	
	while (path = [e nextObject])
	{
		[self addTag:tag ToFile:path];
	}
}

- (void)addTags:(NSArray*)tags ToFiles:(NSArray*)paths
{
	NSEnumerator *e = [paths objectEnumerator];
	NSString *path;
	
	while (path = [e nextObject])
	{
		[self addTags:tags ToFile:path];
	}
}

- (void)removeTag:(PASimpleTag*)tag fromFiles:(NSArray*)files
{
	NSEnumerator *fileEnumerator = [files objectEnumerator];
	NSString *path;
	
	while (path = [fileEnumerator nextObject])
	{
		// get all tags, remove the specified one, write back to file
		NSMutableArray *tags = [self tagsForFile:path];
		[tags removeObject:tag];
		
		// decrement use count here, that way the other classes
		// don't have to care
		[tag decrementUseCount];
		[self writeTags:tags ToFile:path];
	}
}

- (void)removeTags:(NSArray*)tags fromFiles:(NSArray*)files
{
	NSEnumerator *e = [tags objectEnumerator];
	PASimpleTag *tag;
	
	while (tag = [e nextObject])
	{
		[self removeTag:tag fromFiles:files];
	}
}

- (void)renameTag:(PASimpleTag*)tag toTag:(PASimpleTag*)newTag onFiles:(NSArray*)files
{
	NSEnumerator *fileEnumerator = [files objectEnumerator];
	NSString *path;
	
	while (path = [fileEnumerator nextObject])
	{
		// get all tags, rename the specified one (delete/add), write back to file
		NSMutableArray *tags = [self tagsForFile:path];
		[tags removeObject:tag];
		[tags addObject:newTag];
		[self writeTags:tags ToFile:path];
	}
}

//sets the tags, overwrites current ones
- (void)writeTags:(NSArray*)tags ToFile:(NSString*)path {
	//only the names of the tags are written, create tmp array with names only
	NSMutableArray *keywordArray = [[NSMutableArray alloc] init];
	
	NSEnumerator *e = [tags objectEnumerator];
	PATag *tag;
	
	while (tag = [e nextObject]) {
		[keywordArray addObject:[tag name]];
	}
	
	[[Matador sharedInstance] setAttributeForFileAtPath:path name:@"kMDItemKeywords" value:keywordArray];
	[keywordArray release];
}

//read tags - TODO there could be a lot of mem-leaks in here ... check if file exists!!
- (NSMutableArray*)tagsForFile:(NSString*)path {
	NSArray *tagNames = [self keywordsForFile:path];

	NSMutableArray *tags = [NSMutableArray array];
	NSEnumerator *e = [tagNames objectEnumerator];
	NSString *tagName;

	while (tagName = [e nextObject]) {
		PATag *tag = [tagFactory createTagWithName:tagName];
		[tags addObject:tag];
	}				
	
	return tags;
}

- (NSArray*)keywordsForFile:(NSString*)path {
	//carbon api ... can be treated as cocoa objects - TODO check warnings
	MDItemRef *item = MDItemCreate(NULL,path);
	CFTypeRef *keywords = MDItemCopyAttribute(item,@"kMDItemKeywords");
	NSArray *tagNames = (NSArray*)keywords;
	return [tagNames autorelease];
}

#pragma mark singleton stuff
- (void)dealloc {
	[super dealloc];
}

+ (PATagger*)sharedInstance {
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