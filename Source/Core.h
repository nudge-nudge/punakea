/* Controller */
#import <Cocoa/Cocoa.h>
#import "NNTagging/NNTags.h"
#import "NNTagging/NNTaggableObject.h"

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

#import "Sparkle/SUUpdater.h"

#import "PAServices.h"

#import "PTHotkey.h"

//#import "PANotificationReceiver.h"

@interface Core : NSWindowController
{
	IBOutlet NSMenu					*viewMenu;	
	
	IBOutlet NSMenu					*statusMenu;	
	NNTags							*globalTags;
	
	BrowserController				*browserController;	
	TaggerController				*_taggerController;
	PreferenceController			*preferenceController;	
	SidebarController				*sidebarController;
	
	PTHotKey						*taggerHotkey;
	
	NSStatusItem					*statusItem;
	
	NSNotificationCenter			*nc;	
	NSUserDefaults					*userDefaults;
	
	PAServices						*services;
	
	IBOutlet SUUpdater				*updater;
	IBOutlet NSWindow				*busyWindow;
}

- (SUUpdater*)updater;

- (void)createDirectoriesIfNeeded;

// Menu Actions
- (IBAction)addTagSet:(id)sender;

- (IBAction)goHome:(id)sender;
- (IBAction)toggleInfoPane:(id)sender;
- (IBAction)toggleTagsPane:(id)sender;
- (IBAction)goToAllItems:(id)sender;
- (IBAction)goToManageTags:(id)sender;
- (IBAction)showPreferences:(id)sender;

- (IBAction)openFiles:(id)sender;
- (IBAction)delete:(id)sender;
- (IBAction)selectAll:(id)sender;
- (IBAction)tagSearch:(id)sender;

- (IBAction)showBrowser:(id)sender;
- (IBAction)showBrowserResults:(id)sender;
- (IBAction)showBrowserManageTags:(id)sender;
- (IBAction)resetBrowser:(id)sender;

- (IBAction)showTagger:(id)sender;
- (IBAction)showTaggerForObjects:(NSArray*)taggableObjects;

- (IBAction)openWebsite:(id)sender;
- (IBAction)openDonationWebsite:(id)sender;

- (IBAction)cleanTagDB:(id)sender;

- (IBAction)revealInFinder:(id)sender;

- (IBAction)toggleToolbarShown:(id)sender;
- (IBAction)runToolbarCustomizationPalette:(id)sender;


- (IBAction)searchForTags:(NSArray*)someTags;

// misc
- (BOOL)appHasBrowser;

- (BrowserController *)browserController;
- (TaggerController *)taggerController;
- (NSWindow *)busyWindow;

@end
