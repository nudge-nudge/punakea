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
	
	PATag *activeTag;
	NSMutableArray *rectTags;
}

- (PATag*)activeTag;
- (void)setActiveTag:(PATag*)aTag;

@end
