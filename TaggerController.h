/* TaggerController */

#import <Cocoa/Cocoa.h>
#import "PATags.h"
#import "PATagger.h"
#import "PARelatedTags.h"
#import "PATypeAheadFind.h"

@interface TaggerController : NSWindowController
{	
	IBOutlet NSTokenField *tagField;
	
	IBOutlet NSArrayController *fileController;
	IBOutlet NSArrayController *popularTagsController;
	
	NSMutableArray *currentCompleteTagsInField;

	PATags *tags;
	
	NSArray *popularTagsSortDescriptors;
	
	PATagger *tagger;
	PATypeAheadFind *typeAheadFind;
	
	// stuff for related tags
	NSMetadataQuery *query;
	PARelatedTags *relatedTags;
}

- (id)initWithWindowNibName:(NSString*)windowNibName tags:(PATags*)newTags;

- (void)setFiles:(NSMutableArray*)newFiles;
- (NSMutableArray*)currentCompleteTagsInField;
- (void)setCurrentCompleteTagsInField:(NSMutableArray*)newTags;

@end
