//
//  TaggerInterface.h
//  punakea
//
//  Created by Johannes Hoffart on 05.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TaggerInterface : NSObject {

}

//write tags
-(void)addTagToFile:(NSString*)tag filePath:(NSString*)path;
-(void)addTagsToFile:(NSArray*)tags filePath:(NSString*)path;

//read tags - needed as public?
-(NSArray*)getTagsForFile:(NSString*)path;

//deprecated
-(void)writeSpotlightComment;

@end
