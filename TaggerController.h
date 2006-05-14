/* TaggerController */

#import <Cocoa/Cocoa.h>
#import "PATags.h"
#import "PATagger.h"
#import "PATypeAheadFind.h"

@interface TaggerController : NSWindowController
{	
	IBOutlet NSTokenField *tagField;
	NSMutableArray *currentCompleteTagsInField;

	NSMutableArray *files;
	PATags *tags;
	
	PATagger *tagger;
	PATypeAheadFind *typeAheadFind;
}

- (id)initWithWindowNibName:(NSString*)windowNibName tags:(PATags*)newTags;

- (NSMutableArray*)files;
- (void)setFiles:(NSMutableArray*)newFiles;

@end
