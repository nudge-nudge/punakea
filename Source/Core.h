/* Controller */
#import <Cocoa/Cocoa.h>
#import "NNTagging/NNTags.h"
#import "NNTagging/NNTaggableObject.h"
// TODO move this to NNTags
#import "NNTagging/NNTagSave.h"

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
	
	NNTags					*globalTags;
	
	BrowserController		*browserController;
	
	PreferenceController	*preferenceController;
	
	SidebarController		*sidebarController;
	
	NSNotificationCenter	*nc;
	
	NSUserDefaults			*userDefaults;
}

- (SUUpdater*)updater;

// mainmenu actions
- (IBAction)showResults:(id)sender;
- (IBAction)manageTags:(id)sender;
- (IBAction)searchForTag:(NNTag*)aTag;
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
