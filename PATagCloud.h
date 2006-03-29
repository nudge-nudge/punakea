/* PATagCloud */

#import <Cocoa/Cocoa.h>
#import "Controller.h"
#import "PATag.h"
#import "PATagButton.h"

@interface PATagCloud : NSView
{
    IBOutlet NSArrayController *relatedTagsController;
	IBOutlet NSArrayController *selectedTagsController;
	IBOutlet Controller *controller;

	NSArray *currentTags;
	NSMutableDictionary *tagButtonDict; /**< holds the current controls in the view */
	
	NSPoint pointForNextTagRect;
	
	int tagPosition;
}

@end
