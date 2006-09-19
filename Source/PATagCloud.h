/* PATagCloud */

#import <Cocoa/Cocoa.h>
#import <math.h>
#import "PATagCloudController.h"
#import "PATag.h"
#import "PATagButton.h"
#import "PAResultsOutlineView.h"

extern NSSize const PADDING;
extern NSSize const SPACING;

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
	
	NSUserDefaultsController *userDefaultsController; /**< holds user defaults for tag cloud */
	BOOL eyeCandy;
	
	NSViewAnimation *viewAnimation; /**< only one animation concurrently */
	NSMutableArray *viewAnimationCache; /**< animation cache */
	
	NSAttributedString *noRelatedTagsMessage;
}

- (NSMutableDictionary*)tagButtonDict;
- (void)setTagButtonDict:(NSMutableDictionary*)aDict;
- (PATagButton*)activeButton;
- (void)setActiveButton:(PATagButton*)aTag;
- (BrowserViewController*)controller;
- (void)selectUpperLeftButton;

@end
