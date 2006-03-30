/* PATagCloud */

#import <Cocoa/Cocoa.h>
#import "Controller.h"
#import "PATag.h"
#import "PATagButton.h"

@interface PATagCloud : NSView
{
	IBOutlet Controller *controller;

	NSMutableDictionary *tagButtonDict; /**< holds the current controls in the view */
	NSArray *displayTags; /**< holds all the tags to be displayed */
	
	NSPoint pointForNextTagRect;
	
	int tagPosition;
}

- (NSArray*)displayTags;
- (void)setDisplayTags:(NSArray*)otherTags;

@end
