/* Controller */

#import <Cocoa/Cocoa.h>
#import "PATags.h"
#import "PASimpleTagFactory.h"
#import "PATagger.h"

#import "SidebarController.h"
#import "BrowserController.h"

@interface Core : NSWindowController
{
	PATagger *tagger;
}

//saving and loading
- (NSString*)pathForDataFile;
- (void)saveDataToDisk;
- (void)loadDataFromDisk;
- (void)applicationWillTerminate:(NSNotification *)note;

@end
