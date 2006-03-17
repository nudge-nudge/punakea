/* PATagCloud */

#import <Cocoa/Cocoa.h>
#import "Controller.h"
#import "PATag.h"

@interface PATagCloud : NSView
{
    IBOutlet NSArrayController *relatedTagsController;
	IBOutlet NSArrayController *selectedTagsController;

	NSArray *currentTags;
	
	NSPoint pointForNextTagRect;
	
	id <PATag> activeTag;
	NSMutableArray *rectTags;
}

- (id <PATag>)activeTag;
- (void)setActiveTag:(id <PATag>)aTag;

@end
