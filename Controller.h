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
	
	// Renamed from query to _query due to binding issues (like Spotlighter Sample does)
	NSMetadataQuery *_query;
}
- (IBAction)danielTest:(id)sender;
- (IBAction)hoffartTest:(id)sender;

//for NSMetadataQuery
- (NSMetadataQuery *)query;
- (PASelectedTags *)selectedTags;
- (PARelatedTags *)relatedTags;
- (void)selectedTagsHaveChanged;

// For OutlineView Bindings
// - (NSMutableArray *) fileGroups;
@end
