/* PATagButtonCell */

#import <Cocoa/Cocoa.h>
#import "PATag.h"
#import "PATagButton.h"
#import "PAButtonCell.h"
#import "BrowserViewController.h"

extern int const MIN_FONT_SIZE;
extern int const MAX_FONT_SIZE;

/**
cell for the tagcloud, displays the given tag and interacts with the user
 */
@interface PATagButtonCell : PAButtonCell
{
	PATag *fileTag;
	float rating;
}

- (id)initWithTag:(PATag*)aTag rating:(float)aRating;

- (PATag*)fileTag;
- (void)setFileTag:(PATag*)aTag;

- (float)rating;
- (void)setRating:(float)aRating;

@end
