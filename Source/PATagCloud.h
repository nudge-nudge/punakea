/* PATagCloud */

#import <Cocoa/Cocoa.h>
#import <math.h>
#import "PATagCloudController.h"
#import "PATag.h"
#import "PATagButton.h"

//TODO tracking rects are outside of scrollview!
extern NSSize const PADDING;
extern int const SPACING;

/**
displays all [controller visibleTags] in a nice tag cloud view
 */
@interface PATagCloud : NSView
{
	IBOutlet BrowserViewController *controller; /**< controller, holding tags and stuff */

	NSMutableDictionary *tagButtonDict; /**< holds the current controls in the view */
	PATagButton *activeButton; /**< currently selected tag */
	
	NSPoint pointForNextTagRect; /**< saves the point for the next tag to be displayed */
	int tagPosition; /**< holds the position where the new line starts */
	
	NSMutableDictionary *tagCloudSettings; /**< holds user defaults for tag cloud */
	
	NSMutableArray *viewAnimations; /**< animation cache */
}

- (NSMutableDictionary*)tagButtonDict;
- (void)setTagButtonDict:(NSMutableDictionary*)aDict;
- (PATagButton*)activeButton;
- (void)setActiveButton:(PATagButton*)aTag;
- (BrowserViewController*)controller;

@end
