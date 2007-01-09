/* Controller */
#import <Cocoa/Cocoa.h>
#import "PATagging/PATags.h"

#import "SidebarController.h"
#import "BrowserController.h"
#import "PreferenceController.h"
#import "TaggerController.h"
#import "PATagManagementViewController.h"

#import "PABrowserViewMainController.h"
#import "PAResultsViewController.h"
#import "PAResultsOutlineView.h"

#import "PACollectionNotEmpty.h"

#import "Sparkle/SUUpdater.h"

@interface Core : NSWindowController
{
	IBOutlet NSMenu			*viewMenu;
	
	IBOutlet SUUpdater		*updater;
	
	PATags					*globalTags;

	BrowserController		*browserController;
	
	PreferenceController	*preferenceController;
	
	NSNotificationCenter	*nc;
}

- (SUUpdater*)updater;

//saving and loading
- (NSString*)pathForDataFile;
- (void)saveDataToDisk;
- (void)loadDataFromDisk;
- (void)applicationWillTerminate:(NSNotification *)note;

// mainmenu actions
- (IBAction)showResults:(id)sender;
- (IBAction)manageTags:(id)sender;
- (IBAction)showPreferences:(id)sender;

- (IBAction)openFiles:(id)sender;
- (IBAction)deleteFiles:(id)sender;
- (IBAction)editTagsOnFiles:(id)sender;
- (IBAction)selectAll:(id)sender;

- (IBAction)showBrowser:(id)sender;
- (IBAction)showTagger:(id)sender;

- (IBAction)showDonationWebsite:(id)sender;

// misc
- (BOOL)appHasBrowser;

@end
