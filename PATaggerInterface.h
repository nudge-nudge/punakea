//
//  TaggerInterface.h
//  punakea
//
//  Created by Johannes Hoffart on 05.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreServices/CoreServices.h>
#import "PATags.h"
#import "PATag.h"

@interface PATaggerInterface : NSObject {
	NSMetadataQuery *query;
	PATags *tagModel;
}

//get instance
+(PATaggerInterface*)sharedInstance;

//accessors - dictionaries the best? can hold occurenceCount ... discussion ...
-(NSArray*)relatedTags;
-(NSArray*)activeTags;
-(NSMetadataQuery*)query;

//write tags
-(void)addTagToFile:(PATag*)tag filePath:(NSString*)path;
-(void)addTagsToFile:(NSArray*)tags filePath:(NSString*)path;

//get tags
-(NSArray*)getTagsForFile:(NSString*)path;

//update model 
-(void)activeTagsHaveChanged;

@end
