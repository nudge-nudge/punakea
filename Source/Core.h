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

#import "Sparkle/SUUpdater.h"

//#import "PANotificationReceiver.h"

@interface Core : NSWindowController
{
	IBOutlet NSMenu					*viewMenu;	
	
	IBOutlet NSMenu					*statusMenu;	
	NNTags							*globalTags;
	
	BrowserController				*browserController;	
	TaggerController				*taggerController;
	PreferenceController			*preferenceController;	
	SidebarController				*sidebarController;
	
	NSStatusItem					*statusItem;
	
	NSNotificationCenter			*nc;	
	NSUserDefaults					*userDefaults;
	
	IBOutlet SUUpdater				*updater;
}

- (SUUpdater*)updater;

// Menu Actions
- (IBAction)goHome:(id)sender;
- (IBAction)toggleInfo:(id)sender;
- (IBAction)goToLibrary:(id)sender;
- (IBAction)goToManageTags:(id)sender;
- (IBAction)showPreferences:(id)sender;

- (IBAction)openFiles:(id)sender;
- (IBAction)delete:(id)sender;
- (IBAction)editTagsOnFiles:(id)sender;
- (IBAction)selectAll:(id)sender;
- (IBAction)tagSearch:(id)sender;

- (IBAction)showBrowser:(id)sender;
- (IBAction)showTagger:(id)sender;

- (IBAction)openWebsite:(id)sender;
- (IBAction)openDonationWebsite:(id)sender;

- (IBAction)toggleToolbarShown:(id)sender;
- (IBAction)runToolbarCustomizationPalette:(id)sender;


- (IBAction)searchForTag:(NNTag*)aTag;

// misc
- (BOOL)appHasBrowser;

- (BrowserController *)browserController;

@end
