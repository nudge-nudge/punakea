//
//  TaggerInterface.h
//  punakea
//
//  Created by Johannes Hoffart on 05.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PATaggerInterface : NSObject {

}

//write tags
-(void)addTagToFile:(NSString*)tag filePath:(NSString*)path;
-(void)addTagsToFile:(NSArray*)tags filePath:(NSString*)path;
-(void)writeTagsToFile:(NSArray*)tags filePath:(NSString*)path;

//read tags 
-(NSArray*)getTagsForFile:(NSString*)path;
-(NSArray*)getRelatedTagsForTag:(NSString*)tag;

@end
