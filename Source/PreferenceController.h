//
//  PreferenceController.h
//  punakea
//
//  Created by Johannes Hoffart on 29.08.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LoginItemsAE.h"
#import "PATagAutocompleteWindowController.h"

typedef enum _PAScheduledUpdateCheckInterval {
	PAScheduledUpdateCheckDaily = 0,
	PAScheduledUpdateCheckWeekly = 1,
	PAScheduledUpdateCheckMonthly = 2
} PAScheduledUpdateCheckInterval;

@class Core;

@interface PreferenceController : PATagAutocompleteWindowController
{
	IBOutlet NSPopUpButton *managedFolderPopUpButton;
	IBOutlet NSPopUpButton *tagsFolderPopUpButton;
	IBOutlet NSPopUpButton *dropBoxPopUpButton;
	
	IBOutlet NSPopUpButton *updateIntervalButton;
	
	NSUserDefaultsController *userDefaultsController;
	
	Core *core;
}

- (id)initWithCore:(Core*)aCore;

- (IBAction)locateDirectory:(id)sender;
- (IBAction)switchToDefaultDirectory:(id)sender;
- (IBAction)checkForUpdates:(id)sender;

@end
