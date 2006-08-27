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
		simpleTagFactory = [[PASimpleTagFactory alloc] init];
		tags = [[PATags alloc] init];
	}
	return self;
}

#pragma mark tags and files
- (NSArray*)tagsOnFiles:(NSArray*)filePaths
{
	return [self tagsOnFiles:filePaths includeTempTags:YES];
}

- (NSArray*)tagsOnFiles:(NSArray*)filePaths includeTempTags:(BOOL)includeTempTags
{
	NSMutableArray *keywords = [NSMutableArray array];
	
	NSEnumerator *filePathEnumerator = [filePaths objectEnumerator];
	NSString *filePath;
	
	while (filePath = [filePathEnumerator nextObject])
	{
		[keywords addObjectsFromArray:[self keywordsForFile:filePath]];
	}
	
	NSArray *resultTags = [self tagsForNames:keywords includeTempTags:includeTempTags];
	
	return resultTags;	
}

- (PATag*)tagForName:(NSString*)tagName
{
	return [self tagForName:tagName includeTempTag:YES];
}

- (PATag*)tagForName:(NSString*)tagName includeTempTag:(BOOL)includeTempTag
{
	PATag *tag = [tags tagForName:tagName];
	
	if (!tag && includeTempTag)
	{
		tag = [[PATempTag alloc] init];
	}
	
	return tag;
}

- (NSArray*)tagsForNames:(NSArray*)tagNames includeTempTags:(BOOL)includeTempTags
{
	NSMutableArray *result = [NSMutableArray array];
	
	NSEnumerator *e = [tagNames objectEnumerator];
	NSString *tagName;
	
	while (tagName = [e nextObject])
	{
		PATag *tag = [tags tagForName:tagName];
		
		if (!tag && includeTempTags)
		{
			tag = [[PATempTag alloc] initWithName:tagName];
		}
		
		if (tag && ![result containsObject:tag])
		{
			[result addObject:tag];
		}
	}
	
	return result;
}

- (PATag*)createTagForName:(NSString*)tagName
{
	PATag *tag = [self tagForName:tagName includeTempTag:NO];
	
	if (!tag)
	{
		tag = [simpleTagFactory createTagWithName:tagName];
		[tags addTag:tag];
	}
	
	return tag;
}

- (NSArray*)createTagsForNames:(NSArray*)tagNames
{
	NSMutableArray *result = [NSMutableArray array];
	
	NSEnumerator *e = [tagNames objectEnumerator];
	NSString *tagName;
	
	while (tagName = [e nextObject])
	{
		PATag *tag = [self tagForName:tagName includeTempTag:NO];
		
		if (!tag)
		{
			tag = [simpleTagFactory createTagWithName:tagName];
			[tags addTag:tag];
		}
		
		if (![result containsObject:tag])
		{
			[result addObject:tag];
		}
	}
	
	return result;
}

- (NSArray*)keywordsForFile:(NSString*)path {
	//carbon api ... can be treated as cocoa objects - TODO check warnings
	MDItemRef *item = MDItemCreate(NULL,path);
	CFTypeRef *keywords = MDItemCopyAttribute(item,@"kMDItemKeywords");
	NSArray *tagNames = (NSArray*)keywords;
	return [tagNames autorelease];
}

- (void)addTags:(NSArray*)someTags toFiles:(NSArray*)filePaths
{
	NSEnumerator *filePathEnumerator = [filePaths objectEnumerator];
	NSString *filePath;
	
	while (filePath = [filePathEnumerator nextObject])
   {
	   NSMutableArray *tagsOnFile = [[[self tagsOnFiles:[NSArray arrayWithObject:filePath] includeTempTags:YES] mutableCopy] autorelease];
	   NSEnumerator *e = [someTags objectEnumerator];
	   PATag *tag;

	   while (tag = [e nextObject])
	   {
		   if (![tagsOnFile containsObject:tag])
		   {
			   [tagsOnFile addObject:tag];
			   [tag incrementUseCount];
		   }
	   }

	   [self writeTags:tagsOnFile ToFile:filePath];
   }
}

- (void)addKeywords:(NSArray*)keywords toFiles:(NSArray*)filePaths createSimpleTags:(BOOL)createSimpleTags
{
	NSArray *tagArray;
	
	if (createSimpleTags)
	{
		tagArray = [self createTagsForNames:keywords];
	}
	else
	{
		tagArray = [self tagsForNames:keywords includeTempTags:NO];
	}
	
	[self addTags:tagArray toFiles:filePaths];
}

#pragma mark working with tags (renaming and deleting)
- (void)removeTag:(PATag*)tag
{
	PAQuery *query = [[PAQuery alloc] init];
	NSArray *files = [query filesForTag:tag];	
	
	[self removeTag:tag fromFiles:files];
}

- (void)renameTag:(NSString*)tagName toTag:(NSString*)newTagName
{
	PAQuery *query = [[PAQuery alloc] init];
	NSArray *files = [query filesForTag:[self tagForName:tagName]];	
	
	[self renameTag:tagName toTag:newTagName onFiles:files];
}

- (void)removeTag:(PATag*)tag fromFiles:(NSArray*)files
{
	NSEnumerator *fileEnumerator = [files objectEnumerator];
	NSString *path;
	
	while (path = [fileEnumerator nextObject])
	{
		// get all tags, remove the specified one, write back to file
		NSMutableArray *someTags = [[[self tagsOnFiles:[NSArray arrayWithObject:path]] mutableCopy] autorelease];
		[someTags removeObject:tag];
		
		// decrement use count here, that way the other classes
		// don't have to care
		[tag decrementUseCount];
		[self writeTags:someTags ToFile:path];
	}
}

- (void)removeTags:(NSArray*)someTags fromFiles:(NSArray*)files
{
	NSEnumerator *e = [someTags objectEnumerator];
	PASimpleTag *tag;
	
	while (tag = [e nextObject])
	{
		[self removeTag:tag fromFiles:files];
	}
}

- (void)renameTag:(NSString*)tagName toTag:(NSString*)newTagName onFiles:(NSArray*)files
{
	if ([tagName isEqualToString:newTagName])
	{
		// no renaming needed
		return;
	}
	
	NSEnumerator *fileEnumerator = [files objectEnumerator];
	NSString *path;
	
	while (path = [fileEnumerator nextObject])
	{
		// get all tags, rename the specified one (delete/add), write back to file
		NSMutableArray *keywords = [[self keywordsForFile:path] mutableCopy];
		[keywords removeObject:tagName];
		[keywords addObject:newTagName];
		NSArray *newTags = [self createTagsForNames:keywords];
		[self writeTags:newTags ToFile:path];
		[keywords release];
	}
}

//sets the tags, overwrites current ones
- (void)writeTags:(NSArray*)someTags ToFile:(NSString*)path {
	//only the names of the tags are written, create tmp array with names only
	NSMutableArray *keywordArray = [[NSMutableArray alloc] init];
	
	NSEnumerator *e = [someTags objectEnumerator];
	PATag *tag;
	
	while (tag = [e nextObject]) {
		[keywordArray addObject:[tag name]];
	}
	
	[[Matador sharedInstance] setAttributeForFileAtPath:path name:@"kMDItemKeywords" value:keywordArray];
	[keywordArray release];
}

- (NSDictionary*)tagNamesWithCountForFilesAtPaths:(NSArray*)paths;
{
	NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
	
	NSArray *tmpTags = [self tagsOnFiles:paths];
	NSEnumerator *tagEnum = [tmpTags objectEnumerator];
	PATag *tag;
	
	while (tag = [tagEnum nextObject])
	{
		if ([resultDict objectForKey:[tag name]])
		{
			NSNumber *count = [resultDict objectForKey:[tag name]];
			int tmp = [count intValue]+1;
			NSNumber *newCount = [NSNumber numberWithInt:tmp];
			[resultDict setObject:newCount forKey:[tag name]];
		}
		else
		{
			NSNumber *newCount = [NSNumber numberWithInt:1];
			[resultDict setObject:newCount forKey:[tag name]];
		}
	}
	
	return resultDict;
}

#pragma mark accessors
- (PATags*)tags
{
	return tags;
}

- (void)setTags:(PATags*)allTags
{
	[allTags retain];
	[tags release];
	tags = allTags;
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