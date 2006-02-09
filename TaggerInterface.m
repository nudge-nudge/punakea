//
//  TaggerInterface.m
//  punakea
//
//  Created by Johannes Hoffart on 05.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "TaggerInterface.h"
#import "Matador.h"
#import <CoreServices/CoreServices.h>

@implementation TaggerInterface

-(id)init {
	//pool = [NSAutoreleasePool new];
}

//write tags
-(void)addTagToFile:(NSString*)tag filePath:(NSString*)path {
	[self addTagsToFile:[NSArray arrayWithObject:tag] filePath:path];
}


-(void)addTagsToFile:(NSArray*)tags filePath:(NSString*)path {
	//existing tags must be kept
	if ([[self getTagsForFile:path] count] > 0) {
		NSMutableArray *tmpArray = [NSMutableArray arrayWithArray:tags];
		[tmpArray addObjectsFromArray:[self getTagsForFile:path]];
		[tags release];
		tags = tmpArray;
	}
	//write the tags to kMDItemKeywords
	[[Matador sharedInstance] setAttributeForFileAtPath:path name:@"kMDItemKeywords" value:tags];
}

//read tags - TODO there must be a lot of mem-leaks in here ... 
-(NSArray*)getTagsForFile:(NSString*)path {
	//carbon api ... can be treated as cocoa objects
	MDItemRef *item = MDItemCreate(NULL,path);
	CFTypeRef *keywords = MDItemCopyAttribute(item,@"kMDItemKeywords");
	
	return keywords;
}

-(void)dealloc{
	//[pool release];
	[super dealloc];
}

@end
