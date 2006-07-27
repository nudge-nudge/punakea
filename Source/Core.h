/* Controller */

/* TODO global
check useCount increment
*/

#import <Cocoa/Cocoa.h>
#import "PATags.h"
#import "PASimpleTagFactory.h"
#import "PATagger.h"

#import "SidebarController.h"
#import "BrowserController.h"

#import "PATagManagementViewController.h"

@interface Core : NSWindowController
{
	PATagger *tagger;
}

//saving and loading
- (NSString*)pathForDataFile;
- (void)saveDataToDisk;
- (void)loadDataFromDisk;
- (void)applicationWillTerminate:(NSNotification *)note;

// mainmenu actions
- (IBAction)manageTags:(id)sender;

@end
