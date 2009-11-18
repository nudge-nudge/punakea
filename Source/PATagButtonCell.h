/* PATagButtonCell */

#import <Cocoa/Cocoa.h>
#import "NNTagging/NNTag.h"
#import "PATagButton.h"
#import "PAButtonCell.h"
#import "BrowserViewController.h"

extern NSInteger const MIN_FONT_SIZE;
extern NSInteger const MAX_FONT_SIZE;

/**
cell for the tagcloud, displays the given tag and interacts with the user
 */
@interface PATagButtonCell : PAButtonCell
{
	NNTag *genericTag;
	CGFloat rating;
}

- (id)initWithTag:(NNTag*)aTag rating:(CGFloat)aRating;

- (NNTag*)genericTag;
- (void)setGenericTag:(NNTag*)aTag;

- (CGFloat)rating;
- (void)setRating:(CGFloat)aRating;

@end
