//
//  TaggerInterface.m
//  punakea
//
//  Created by Johannes Hoffart on 05.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PATagger.h"

@interface PATagger (PrivateAPI)

- (void)writeTagsToFile:(NSArray*)tags filePath:(NSString*)path;

@end

@implementation PATagger

//this is where the sharedInstance is held
static PATagger *sharedInstance = nil;

//constructor - only called by sharedInstance
- (id)sharedInstanceInit {
	self = [super init];
	if (self)
	{
		tagFactory = [[PASimpleTagFactory alloc] init];
	}
	return self;
}

//write tags
- (void)addTagToFile:(PASimpleTag*)tag filePath:(NSString*)path {
	[self addTagsToFile:[NSArray arrayWithObject:tag] filePath:path];
}

//adds the specified tags, doesn't overwrite - TODO check if works with PATag
- (void)addTagsToFile:(NSArray*)tags filePath:(NSString*)path {
	NSMutableArray *resultTags = [NSMutableArray arrayWithArray:tags];
	
	//existing tags must be kept - only if there are any
	if ([[self getTagsForFile:path] count] > 0) {
		NSArray *currentTags = [self getTagsForFile:path];

		/* check if the file had tags which are not in the
		   tags to be added - need to keep them */
		NSEnumerator *e = [currentTags objectEnumerator];
		id tag;
		
		while ( (tag = [e nextObject]) ) {
			if (![resultTags containsObject:tag]) {
				[resultTags addObject:tag];
			}
		}
	}
	
	//write the tags to kMDItemKeywords - new and existing ones
	[self writeTagsToFile:resultTags filePath:path];
}

- (void)removeTag:(PASimpleTag*)tag fromFiles:(NSArray*)files
{
	NSEnumerator *fileEnumerator = [files objectEnumerator];
	NSString *path;
	
	while (path = [fileEnumerator nextObject])
	{
		// get all tags, remove the specified one, write back to file
		NSMutableArray *tags = [self getTagsForFile:path];
		[tags removeObject:tag];
		[self writeTagsToFile:tags filePath:path];
	}
}

- (void)renameTag:(PASimpleTag*)tag toTag:(PASimpleTag*)newTag onFiles:(NSArray*)files
{
	NSEnumerator *fileEnumerator = [files objectEnumerator];
	NSString *path;
	
	while (path = [fileEnumerator nextObject])
	{
		// get all tags, rename the specified one (delete/add), write back to file
		NSMutableArray *tags = [self getTagsForFile:path];
		[tags removeObject:tag];
		[tags addObject:newTag];
		[self writeTagsToFile:tags filePath:path];
	}
}

//sets the tags, overwrites current ones
- (void)writeTagsToFile:(NSArray*)tags filePath:(NSString*)path {
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
//TODO BUG tags don't get all the proper values from the main array (controller tags)!!!
- (NSMutableArray*)getTagsForFile:(NSString*)path {
	//carbon api ... can be treated as cocoa objects - TODO check warnings
	MDItemRef *item = MDItemCreate(NULL,path);
	CFTypeRef *keywords = MDItemCopyAttribute(item,@"kMDItemKeywords");
	NSArray *tagNames = (NSArray*)keywords;
	NSMutableArray* tags = [[NSMutableArray alloc] init];

	NSEnumerator *e = [tagNames objectEnumerator];
	NSString *tagName;

	while (tagName = [e nextObject]) {
		PATag *tag = [tagFactory createTagWithName:tagName];
		[tags addObject:tag];
		[tag release];
	}				
	
	return [tags autorelease];
}

//TODO might never be called - check if needed
- (void)dealloc {
	[super dealloc];
}

#pragma mark singleton stuff
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