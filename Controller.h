/* Controller */

#import <Cocoa/Cocoa.h>
#import "PATaggerInterface.h"
#import "PASelectedTags.h"
#import "PARelatedTags.h"

@interface Controller : NSWindowController
{
    IBOutlet id drawer;
    IBOutlet NSTextField *textfieldDaniel;
    IBOutlet NSTextField *textfieldJohannes;
	NSView *sidebarNibView;
	PATaggerInterface *ti;
	
	// For OutlineView Bindings
	NSMutableArray *fileGroups;
	NSMutableString *myString;
	
	//Spotlight query stuff
	PASelectedTags *selectedTags;
	PARelatedTags *relatedTags;
	NSMetadataQuery *query;
}
- (IBAction)danielTest:(id)sender;
- (IBAction)hoffartTest:(id)sender;

- (void)selectedTagsHaveChanged;

// For OutlineView Bindings
// - (NSMutableArray *) fileGroups;
@end
