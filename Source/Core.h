/* Controller */
#import <Cocoa/Cocoa.h>
#import "PATagging/PATags.h"
#import "PATagging/PATaggableObject.h"
// TODO move this to PATags
#import "PATagging/PATagSave.h"

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

//#import "PANotificationReceiver.h"

@interface Core : NSWindowController
{
	IBOutlet NSMenu			*viewMenu;
	
	IBOutlet SUUpdater		*updater;
	
	PATags					*globalTags;
	PATagSave				*tagSave;
	
	BrowserController		*browserController;
	
	PreferenceController	*preferenceController;
	
	SidebarController		*sidebarController;
	
	NSNotificationCenter	*nc;
	
	NSUserDefaults			*userDefaults;
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
