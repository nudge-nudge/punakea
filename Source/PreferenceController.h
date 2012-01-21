// Copyright (c) 2006-2011 nudge:nudge (Johannes Hoffart & Daniel Bär). All rights reserved.
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Cocoa/Cocoa.h>
#import "LoginItemsAE.h"
//#import "NNTagging/NSFileManager+TrashFile.h"
#import "BusyWindowController.h"
#import "NNTagging/NNTagging.h"
#import "NNTagging/NNTags.h"
#import "TagAutoCompleteController.h"
#import "ShortcutRecorder/SRRecorderControl.h";


typedef enum _PAScheduledUpdateCheckInterval {
	PAScheduledUpdateCheckDaily = 0,
	PAScheduledUpdateCheckWeekly = 1,
	PAScheduledUpdateCheckMonthly = 2
} PAScheduledUpdateCheckInterval;

extern NSString * const MANAGED_FOLDER_LOCATION_CONTROLLER_KEYPATH;
extern NSString * const TAGS_FOLDER_LOCATION_CONTROLLER_KEYPATH;
extern NSString * const DROP_BOX_LOCATION_CONTROLLER_KEYPATH;

extern NSString * const DROP_BOX_SCRIPTNAME;


@class Core;


@interface PreferenceController : NSWindowController
{
	IBOutlet NSTabView			*tabView;
	
	IBOutlet NSTokenField		*tagField;
	
	IBOutlet NSPopUpButton		*managedFolderPopUpButton;
	IBOutlet NSPopUpButton		*tagsFolderPopUpButton;
	IBOutlet NSPopUpButton		*dropBoxPopUpButton;
	
	IBOutlet NSPopUpButton		*updateIntervalButton;
	
	IBOutlet SRRecorderControl	*hotkeyRecorderControl;
	
	NSUserDefaultsController	*userDefaultsController;
	
	Core						*core;
}

- (id)initWithCore:(Core*)aCore;

- (IBAction)locateDirectory:(id)sender;
- (IBAction)switchSpecialFolderDirToDefault:(id)sender;

@end
