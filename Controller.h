/* Controller */

#import <Cocoa/Cocoa.h>
#import "PATaggerInterface.h"
#import "PASelectedTagsController.h"
#import "PARelatedTagsController.h"

@interface Controller : NSWindowController
{
    IBOutlet id drawer;
    IBOutlet NSTextField *textfieldDaniel;
    IBOutlet NSTextField *textfieldJohannes;
	IBOutlet PASelectedTagsController *selectedTagsController;
	IBOutlet PARelatedTagsController *relatedTagsController;
	
	NSView *sidebarNibView;
	PATaggerInterface *ti;
	
	// For OutlineView Bindings
	NSMutableArray *fileGroups;
	NSMutableString *myString;
	
	// Renamed from query to _query due to binding issues (like Spotlighter Sample does)
	NSMetadataQuery *_query;
}
- (IBAction)danielTest:(id)sender;
- (IBAction)hoffartTest:(id)sender;

//for NSMetadataQuery
- (NSMetadataQuery *)query;
- (void)selectedTagsHaveChanged;

// For OutlineView Bindings
// - (NSMutableArray *) fileGroups;
@end
