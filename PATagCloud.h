/* PATagCloud */

#import <Cocoa/Cocoa.h>
#import "PATagCloudController.h"
#import "PATag.h"
#import "PATagButton.h"

/**
displays all visibleTags in a nice tag cloud view
 */
@interface PATagCloud : NSView
{
	IBOutlet Controller *controller; /**< main controller */

	NSMutableDictionary *tagButtonDict; /**< holds the current controls in the view */
	NSArray *displayTags; /**< holds all the tags to be displayed */
	
	NSPoint pointForNextTagRect; /**< saves the point for the next tag to be displayed */
	
	int tagPosition; /**< holds the position where the new line starts */
}

- (NSArray*)displayTags;
- (void)setDisplayTags:(NSArray*)otherTags;

@end
