// Copyright (c) 2006-2011 nudge:nudge (Johannes Hoffart & Daniel BŠr). All rights reserved.
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

/* Controller */
#import <Cocoa/Cocoa.h>

#import "NNTagging/NNTags.h"
#import "NNTagging/NNTaggableObject.h"
#import "NNTagging/NNTagging.h"
#import "NNTagging/NNFolderToTagImporter.h"

#import "NSApplication+SystemVersion.h"

#import "SidebarController.h"
#import "BrowserController.h"
#import "TaggerController.h"
#import "PreferenceController.h"
#import "TaggerController.h"
#import "PATagManagementViewController.h"

#import "PABrowserViewMainController.h"
#import "PAResultsViewController.h"
#import "PAResultsOutlineView.h"
#import "PASourcePanel.h"
#import "PASourceItem.h"

#import "PATagCache.h"

#import "PACollectionNotEmpty.h"
#import "PABoolToColorTransformer.h"

#import "PAInstaller.h"

#import "PAServices.h"

#import "PTHotkey.h"

#import "UKCrashReporter.h"

#import "NNActiveAppSavingPanel.h"

#import "STPrivilegedTask.h"

#import "lcl.h"

//#import "PANotificationReceiver.h"

@interface Core : NSWindowController
{
	IBOutlet NSMenu					*viewMenu;
	IBOutlet NSMenuItem				*arrangeByMenuItem;
	
	IBOutlet NSMenu					*statusMenu;	
	NNTags							*globalTags;
	NNTagging						*tagging;
	
	BrowserController				*browserController;	
	TaggerController				*_taggerController;
	PreferenceController			*preferenceController;	
	SidebarController				*sidebarController;
	
	PTHotKey						*taggerHotkey;
	
	NSStatusItem					*statusItem;
		
	NSUserDefaults					*userDefaults;
	
	PAServices						*services;
	
	IBOutlet NSWindow				*busyWindow;
}

- (void)createDirectoriesIfNeeded;

// Menu Actions
- (IBAction)purchase:(id)sender;
- (IBAction)enterLicenseKey:(id)sender;

- (IBAction)addTagSet:(id)sender;
- (IBAction)getInfo:(id)sender;

- (IBAction)goHome:(id)sender;
- (IBAction)toggleInfoPane:(id)sender;
- (IBAction)toggleTagsPane:(id)sender;
- (IBAction)goToAllItems:(id)sender;
- (IBAction)goToManageTags:(id)sender;
- (IBAction)arrangeBy:(id)sender;
- (IBAction)toggleResultsGrouping:(id)sender;
- (IBAction)toggleFullScreen:(id)sender;

- (IBAction)showPreferences:(id)sender;

- (IBAction)openFiles:(id)sender;
- (IBAction)delete:(id)sender;
- (IBAction)selectAll:(id)sender;
- (IBAction)findTag:(id)sender;
- (IBAction)findInResults:(id)sender;

- (IBAction)showBrowser:(id)sender;
- (IBAction)showBrowserResults:(id)sender;
- (IBAction)showBrowserManageTags:(id)sender;
- (IBAction)resetBrowser:(id)sender;

- (IBAction)showTagger:(id)sender;
- (IBAction)showTaggerActivatingLastActiveApp:(BOOL)activatesLastActiveApp;
- (IBAction)showTaggerForObjects:(NSArray*)taggableObjects;

- (IBAction)openFAQ:(id)sender;
- (IBAction)openScreencast:(id)sender;
- (IBAction)openWebsite:(id)sender;

- (IBAction)syncTags:(id)sender;
- (IBAction)enableSpotlightIndexingOnVolume:(id)sender;

- (IBAction)revealInFinder:(id)sender;

- (IBAction)toggleToolbarShown:(id)sender;
- (IBAction)runToolbarCustomizationPalette:(id)sender;

- (IBAction)importFolder:(id)sender;

- (IBAction)searchForTags:(NSArray*)someTags;

// misc
- (BOOL)appHasBrowser;

- (BrowserController *)browserController;
- (TaggerController *)taggerController;
- (NSWindow *)busyWindow;
- (NSMenuItem*)arrangeByMenuItem;

@end
