/* PATagButtonCell */

#import <Cocoa/Cocoa.h>
#import "PATagging/PATag.h"
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
	PATag *genericTag;
	float rating;
}

- (id)initWithTag:(PATag*)aTag rating:(float)aRating;

- (PATag*)genericTag;
- (void)setGenericTag:(PATag*)aTag;

- (float)rating;
- (void)setRating:(float)aRating;

@end
