/* Controller */

#import <Cocoa/Cocoa.h>
#import "PATagger.h"
#import "PASelectedTagsController.h"
#import "PARelatedTagsController.h"
#import "PAFileMatrix.h"

@interface Controller : NSWindowController
{
    IBOutlet id drawer;
    IBOutlet NSOutlineView *outlineView;
	IBOutlet PASelectedTagsController *selectedTagsController;
	IBOutlet PARelatedTagsController *relatedTagsController;
	IBOutlet PAFileMatrix *fileMatrix;
	
	NSView *sidebarNibView;
	
	PATagger *tagger;
	NSMutableArray *tags;
	
	// Renamed from query to _query due to binding issues (like Spotlighter Sample does)
	NSMetadataQuery *_query;
}

- (IBAction)danielTest:(id)sender;
- (IBAction)hoffartTest:(id)sender;

//saving and loading
- (NSString*) pathForDataFile;
- (void) saveDataToDisk;
- (void) loadDataFromDisk;

- (void) applicationWillTerminate: (NSNotification *) note;

- (NSMutableArray*) tags;
- (void) setTags: (NSMutableArray*) otherTags;

//for NSMetadataQuery
- (NSMetadataQuery *)query;
- (void)selectedTagsHaveChanged;

// For OutlineView Bindings
// - (NSMutableArray *) fileGroups;
@end
