/* Controller */

#import <Cocoa/Cocoa.h>
#import "PATags.h"
#import "PARelatedTags.h"
#import "PASelectedTags.h"
#import "PASimpleTagFactory.h"
#import "SubViewController.h"
#import "PATagger.h"
#import "PAResultsOutlineView.h"
#import "PATypeAheadFind.h"
#import "PAQuery.h"

@interface Controller : NSWindowController
{
	//gui
    IBOutlet id drawer;
    IBOutlet PAResultsOutlineView *outlineView;
	NSView *sidebarNibView;

	//model
	PATags *tags; /**< holds all tags */
	PARelatedTags *relatedTags;
	PASelectedTags *selectedTags;
	
	//controller
	PATagger *tagger;
	PASimpleTagFactory *simpleTagFactory;
	PATag *currentBestTag; /**< holds the tag with the highest absolute rating currently in visibleTags */
	
	NSMutableArray *visibleTags; /**< holds tags for TagCloud */
	
	PATypeAheadFind *typeAheadFind; /**< used for type ahead find */
	
	// Renamed from query to _query due to binding issues (like Spotlighter Sample does)
	NSMetadataQuery *_query;
}

//saving and loading
- (NSString*)pathForDataFile;
- (void)saveDataToDisk;
- (void)loadDataFromDisk;
- (void)applicationWillTerminate:(NSNotification *)note;

//accessors
- (PATags*)tags;
- (void)setTags:(PATags*)otherTags;
- (PARelatedTags*)relatedTags;
- (void)setRelatedTags:(PARelatedTags*)otherRelatedTags;
- (PASelectedTags*)selectedTags;
- (void)setSelectedTags:(PASelectedTags*)otherSelectedTags;

- (NSMutableArray*)visibleTags;
- (void)setVisibleTags:(NSMutableArray*)otherTags;
- (PATag*)currentBestTag;
- (void)setCurrentBestTag:(PATag*)otherTag;

//for NSMetadataQuery
- (NSMetadataQuery *)query;
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;

//for adding to selected
- (IBAction)clearSelectedTags:(id)sender;

// Temp
- (IBAction)setGroupingAttributes:(id)sender;

@end
