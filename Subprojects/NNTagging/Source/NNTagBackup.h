//
//  NNTagBackup.h
//  NNTagging
//
//  Created by Johannes Hoffart on 27.03.09.
//  Copyright 2009 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "NNTagStoreManager.h"
#import "NNTagToFileWriter.h"

#import "NNFile.h"

extern NSString * const nntaggingApplicationSupport;

@interface NNTagBackup : NSObject {

}

/**
 Creates a backup of all files (TODO only supports files at the moment, architecture
 is not completely generic there at the moment)
 
 @return YES if successful, NO otherwise
 */
+ (BOOL)createBackup;

/**
 Restores the tags on tagged files from the most recent backup
 */
+ (void)restoreFromBackup;

@end
