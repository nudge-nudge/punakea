/* Controller */

#import <Cocoa/Cocoa.h>
#import "PATagger.h"
#import "PARelatedTags.h"
#import "SubViewController.h"
#import "PATagger.h"
#import "PAResultsOutlineView.h"

@interface Controller : NSWindowController
{
    IBOutlet id drawer;
    IBOutlet PAResultsOutlineView *outlineView;
	IBOutlet NSArrayController *relatedTagsController;
	IBOutlet NSArrayController *selectedTagsController;
	IBOutlet NSArrayController *resultController;
	
	NSView *sidebarNibView;
	
	PATagger *tagger;
	
	NSMutableArray *tags; /**< holds all tags */
	NSMutableArray *visibleTags; /**< holds tags for TagCloud */
	PATag *currentBestTag; /**< holds the tag with the highest absolute rating currently in visibleTags */
	
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
- (PATag*)currentBestTag;
- (void)setCurrentBestTag:(PATag*)otherTag;

//for NSMetadataQuery
- (NSMetadataQuery *)query;
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;

//for adding to selected
- (NSDictionary*)viewAttributesForTag:(PATag*)tag;
- (void)addToSelectedTags;
- (IBAction)clearSelectedTags:(id)sender;

- (void)openFile;

// Temp
- (IBAction)setGroupingAttributes:(id)sender;

@end
