//
//  TaggerInterface.h
//  punakea
//
//  Created by Johannes Hoffart on 05.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreServices/CoreServices.h>
#import "PASelectedTags.h"
#import "PATag.h"

@interface PATaggerInterface : NSObject

//get instance
+(PATaggerInterface*)sharedInstance;

//write tags
-(void)addTagToFile:(PATag*)tag filePath:(NSString*)path;
-(void)addTagsToFile:(NSArray*)tags filePath:(NSString*)path;

//get tags
-(NSArray*)getTagsForFile:(NSString*)path;

@end
