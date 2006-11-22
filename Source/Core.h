/* Controller */
#import <Cocoa/Cocoa.h>
#import "PATags.h"
#import "PASimpleTagFactory.h"
#import "PATagger.h"

#import "SidebarController.h"
#import "BrowserController.h"
#import "PreferenceController.h"
#import "TaggerController.h"
#import "PATagManagementViewController.h"

#import "PABrowserViewMainController.h"
#import "PAResultsViewController.h"
#import "PAResultsOutlineView.h"

#import "PACollectionNotEmpty.h"


@interface Core : NSWindowController
{
	IBOutlet NSMenu			*viewMenu;
	
	PATagger				*tagger;

	BrowserController		*browserController;
	PreferenceController	*preferenceController;
	
	NSNotificationCenter	*nc;
}

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

- (IBAction)showBrowser:(id)sender;
- (void)closeBrowser;
- (IBAction)showTagger:(id)sender;

@end
