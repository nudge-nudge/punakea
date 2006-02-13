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

@interface PATaggerInterface : NSObject {
	NSMetadataQuery *relatedTagsQuery;
	NSMetadataQuery *filesQuery;
	NSString *tagPrefix;
	PATags *tagModel;
}

//accessors - dictionaries the best? can hold occurenceCount ... discussion ...
-(NSArray*)relatedTags;
-(NSArray*)activeTags;
-(NSMetadataQuery*)activeFiles;

//write tags
-(void)addTagToFile:(NSString*)tags filePath:(NSString*)path;
-(void)addTagsToFile:(NSArray*)tags filePath:(NSString*)path;

//update model 
-(void)activeTagsHaveChanged;

@end
