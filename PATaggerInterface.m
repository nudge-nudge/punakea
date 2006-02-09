//
//  TaggerInterface.m
//  punakea
//
//  Created by Johannes Hoffart on 05.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PATaggerInterface.h"
#import "Matador.h"
#import <CoreServices/CoreServices.h>

@implementation PATaggerInterface

-(id)init {
	return self;
}

//write tags
-(void)addTagToFile:(NSString*)tag filePath:(NSString*)path {
	[self addTagsToFile:[NSArray arrayWithObject:tag] filePath:path];
}

//adds the specified tags, doesn't overwrite
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
	[[Matador sharedInstance] setAttributeForFileAtPath:path name:@"kMDItemKeywords" value:tags];
}

//read tags - TODO there could be a lot of mem-leaks in here ... 
-(NSArray*)getTagsForFile:(NSString*)path {
	//carbon api ... can be treated as cocoa objects
	MDItemRef *item = MDItemCreate(NULL,path);
	CFTypeRef *keywords = MDItemCopyAttribute(item,@"kMDItemKeywords");
	return keywords;
}

-(void)dealloc{
	[super dealloc];
}

@end
