/* Controller */

#import <Cocoa/Cocoa.h>
#import "PATagger.h"
#import "PARelatedTags.h"
#import "PAMetaMatrixView.h"
#import "SubViewController.h"
#import "PATagger.h"

@interface Controller : NSWindowController
{
    IBOutlet id drawer;
    IBOutlet NSOutlineView *outlineView;
	IBOutlet PAMetaMatrixView *metaMatrix;
	IBOutlet NSArrayController *relatedTagsController;
	IBOutlet NSArrayController *selectedTagsController;
	IBOutlet NSArrayController *resultController;
	
	NSView *sidebarNibView;
	
	PATagger *tagger;
	
	NSMutableArray *tags; /**< holds all tags */
	NSMutableArray *visibleTags; /**< holds tags for TagCloud */
	
	PARelatedTags *relatedTags;
	
	// Renamed from query to _query due to binding issues (like Spotlighter Sample does)
	NSMetadataQuery *_query;
}

//saving and loading
- (NSString*)pathForDataFile;
- (void)saveDataToDisk;
- (void)loadDataFromDisk;
- (void)applicationWillTerminate:(NSNotification *)note;

//accessors
- (NSMutableArray*)tags;
- (void)setTags:(NSMutableArray*)otherTags;
- (NSMutableArray*)visibleTags;
- (void)setVisibleTags:(NSMutableArray*)otherTags;

//for NSMetadataQuery
- (NSMetadataQuery *)query;
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;

//for adding to selected
- (void)addToSelectedTags;
- (IBAction)clearSelectedTags:(id)sender;

- (void)openFile;

// Temp
- (IBAction)setGroupingAttributes:(id)sender;

@end
