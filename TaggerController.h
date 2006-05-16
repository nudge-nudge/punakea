/* TaggerController */

#import <Cocoa/Cocoa.h>
#import "PATags.h"
#import "PATagger.h"
#import "PARelatedTags.h"
#import "PATypeAheadFind.h"

@interface TaggerController : NSWindowController
{	
	IBOutlet NSTokenField *tagField;
	IBOutlet NSArrayController *popularTags;
	
	NSMutableArray *currentCompleteTagsInField;

	NSMutableArray *files;

	PATags *tags;
	
	NSArray *popularTagsSortDescriptors;
	
	PATagger *tagger;
	PATypeAheadFind *typeAheadFind;
	
	// stuff for related tags
	NSMetadataQuery *query;
	PARelatedTags *relatedTags;
}

- (id)initWithWindowNibName:(NSString*)windowNibName tags:(PATags*)newTags;

- (NSMutableArray*)files;
- (void)setFiles:(NSMutableArray*)newFiles;
- (NSArray*)currentCompleteTagsInField;
- (void)setCurrentCompleteTagsInField:(NSArray*)newTags;

@end
