//
//  TaggerInterface.m
//  punakea
//
//  Created by Johannes Hoffart on 05.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <CoreServices/CoreServices.h>
#import "PATagger.h"
#import "Matador.h"

@implementation PATagger

//this is where the sharedInstance is held
static PATagger *sharedInstance = nil;

//constructor - only called by sharedInstance
-(id)sharedInstanceInit {
	self = [super init];
	return self;
}

//write tags
-(void)addTagToFile:(PATag*)tag filePath:(NSString*)path {
	[self addTagsToFile:[NSArray arrayWithObject:tag] filePath:path];
}

//adds the specified tags, doesn't overwrite - TODO check if works with PATag
-(void)addTagsToFile:(NSArray*)tags filePath:(NSString*)path {
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

//sets the tags, overwrites current ones
-(void)writeTagsToFile:(NSArray*)tags filePath:(NSString*)path {
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
-(NSArray*)getTagsForFile:(NSString*)path {
	//carbon api ... can be treated as cocoa objects - TODO check warnings
	MDItemRef *item = MDItemCreate(NULL,path);
	CFTypeRef *keywords = MDItemCopyAttribute(item,@"kMDItemKeywords");
	NSArray *tagNames = (NSArray*)keywords;
	NSMutableArray* tags = [[NSMutableArray alloc] init];

	NSEnumerator *e = [tagNames objectEnumerator];
	NSString *tagName;

	while (tagName = [e nextObject]) {
		PATag *tag = [[PATag alloc] initWithName:tagName];
		[tags addObject:tag];
		[tag release];
	}				
	
	return [tags autorelease];
}

//TODO might never be called - check if needed
-(void)dealloc {
	[super dealloc];
}

//---- BEGIN singleton stuff ----
+(PATagger*)sharedInstance {
	@synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[self alloc] sharedInstanceInit];
        }
    }
    return sharedInstance;
}

+(id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
        }
    }
    return sharedInstance;
}

-(id)retain {
    return self;
}

-(unsigned)retainCount {
    return UINT_MAX;  //denotes an object that cannot be released
}

-(void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}
//---- END singleton stuff ----

@end