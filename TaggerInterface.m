//
//  TaggerInterface.m
//  punakea
//
//  Created by Johannes Hoffart on 05.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "TaggerInterface.h"
#import "Matador.h"

@implementation TaggerInterface

//write tags
-(void)addTagToFile:(NSString*)tag filePath:(NSString*)path {
	[self addTagsToFile:[NSArray arrayWithObject:tag] filePath:path];
}

-(void)addTagsToFile:(NSArray*)tags filePath:(NSString*)path {
	//existing tags must be kept
	if ([[self getTagsForFile:path] count] > 0) {
		NSMutableArray *tmpArray = [NSMutableArray arrayWithArray:tags];
		[tags release];
		tags = tmpArray;
	}
	//write the tags to kMDItemKeywords
	[[Matador sharedInstance] setAttributeForFileAtPath:path name:@"kMDItemKeywords" value:tags];
}

//read tags - if needed TODO
-(NSArray*)getTagsForFile:(NSString*)path {
	//nothing
	return [NSArray new];
}

//deprecated
-(void)writeSpotlightComment {
	NSLog(@"rennt weiter");
	NSMutableArray *tags = [NSMutableArray new];
	[tags addObject:@"testtag"];
	[tags addObject:@"ein schoener tag"];
	NSLog([tags objectAtIndex:0]);
	[[Matador sharedInstance] setAttributeForFileAtPath:@"/Users/darklight/Desktop/punakea_test" name:@"kMDItemKeywords" value:tags];
}
@end
