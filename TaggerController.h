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
	
	/** helper for the delegate methods - this is needed
		because shouldAddObjects is called when tags already on the files
		are written in the tagField. when multiple files are dropped, this
		behaviour is unwanted */
	BOOL filesHaveChanged; 
	
	// stuff for related tags
	NSMetadataQuery *query;
	PARelatedTags *relatedTags;
}

- (id)initWithWindowNibName:(NSString*)windowNibName tags:(PATags*)newTags;

- (NSMutableArray*)files;
- (void)setFiles:(NSMutableArray*)newFiles;
- (NSMutableArray*)currentCompleteTagsInField;
- (void)setCurrentCompleteTagsInField:(NSMutableArray*)newTags;

@end
