/* Controller */

/*
 \todo check useCount increment
 \todo empty related tags on selected tags change so taht they don't "flash" in
*/

#import <Cocoa/Cocoa.h>
#import "PATags.h"
#import "PASimpleTagFactory.h"
#import "PATagger.h"

#import "SidebarController.h"
#import "BrowserController.h"
#import "PreferenceController.h"

#import "PATagManagementViewController.h"

@interface Core : NSWindowController
{
	PATagger *tagger;
	PreferenceController *preferenceController;
	
	NSNotificationCenter *nc;
}

//saving and loading
- (NSString*)pathForDataFile;
- (void)saveDataToDisk;
- (void)loadDataFromDisk;
- (void)applicationWillTerminate:(NSNotification *)note;

// mainmenu actions
- (IBAction)manageTags:(id)sender;
- (IBAction)showPreferences:(id)sender;

@end
