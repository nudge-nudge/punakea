//
//  PAInstaller.h
//  punakea
//
//  Created by Johannes Hoffart on 22.05.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "NNTagging/NNTagStoreManager.h"
#import "NNTagging/NNTagBackup.h"

@class NNTagToFileWriter;
@class NNSecureTagToFileWriter;
@class NNTagToOpenMetaWriter;
@class NNFile;

/**
use this class to do stuff Punakea needs to perform on startup
 */
@interface PAInstaller : NSWindowController {

	IBOutlet NSWindow				*openMetaMigrationWindow;
	IBOutlet NSProgressIndicator	*openMetaProgressIndicator;
	
}

+ (void)install;

- (IBAction)migrateSpotlightCommentsToOpenMeta:(id)sender;

- (IBAction)stopModal:(id)sender;
- (IBAction)terminate:(id)sender;

@end
