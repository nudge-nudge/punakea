//
//  PAFileManager.h
//  punakea
//
//  Created by Johannes Hoffart on 04.09.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PAFileManager : NSObject {
	BOOL manageFiles;
	
	NSFileManager *fileManager;
}

- (void)handleFile:(NSString*)filePath;
- (void)handleFiles:(NSArray*)filePaths;

@end
