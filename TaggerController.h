/* TaggerController */

#import <Cocoa/Cocoa.h>
#import "PATags.h"
#import "PATypeAheadFind.h"

@interface TaggerController : NSWindowController
{
	IBOutlet NSTokenField *tokenField;
	
	NSMutableArray *files;
	PATags *tags;
	
	PATypeAheadFind *typeAheadFind;
}

- (id)initWithWindowNibName:(NSString*)windowNibName tags:(PATags*)newTags;

- (NSMutableArray*)files;
- (void)setFiles:(NSMutableArray*)newFiles;

@end
