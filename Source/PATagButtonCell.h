/* PATagButtonCell */

#import <Cocoa/Cocoa.h>
#import "NNTagging/NNTag.h"
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
	NNTag *genericTag;
	float rating;
}

- (id)initWithTag:(NNTag*)aTag rating:(float)aRating;

- (NNTag*)genericTag;
- (void)setGenericTag:(NNTag*)aTag;

- (float)rating;
- (void)setRating:(float)aRating;

@end
