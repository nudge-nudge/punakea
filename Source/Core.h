/* Controller */

#import <Cocoa/Cocoa.h>
#import "PATags.h"
#import "PARelatedTags.h"
#import "PASelectedTags.h"
#import "PASimpleTagFactory.h"
#import "PATagger.h"
#import "PAResultsOutlineView.h"
#import "PATypeAheadFind.h"
#import "PAQuery.h"
#import "BrowserController.h"

@interface Controller : NSWindowController
{
	//model
	PATags *tags; /**< holds all tags */

	//controller
	PATagger *tagger;
	PASimpleTagFactory *simpleTagFactory;
}

//saving and loading
- (NSString*)pathForDataFile;
- (void)saveDataToDisk;
- (void)loadDataFromDisk;
- (void)applicationWillTerminate:(NSNotification *)note;

//accessors
- (PATags*)tags;
- (void)setTags:(PATags*)otherTags;

@end
