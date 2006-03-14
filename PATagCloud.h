/* PATagCloud */

#import <Cocoa/Cocoa.h>
#import "Controller.h"
#import "PATag.h"

@interface PATagCloud : NSView
{
    IBOutlet NSArrayController *relatedTagsController;
	IBOutlet NSArrayController *selectedTagsController;
	NSPoint pointForTagRect;
	PATag *activeTag;
}

- (PATag*)activeTag;
- (void)setActiveTag:(PATag*)aTag;

@end
