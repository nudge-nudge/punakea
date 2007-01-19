/* PATagButton */

#import <Cocoa/Cocoa.h>
#import "NNTagging/NNTag.h"
#import "PAButton.h"
#import "PATagButtonCell.h"
#import "PADropManager.h"

@interface PATagButton : PAButton {
	PADropManager			*dropManager;		
}

- (id)initWithTag:(NNTag*)tag rating:(float)rating;

- (NNTag*)genericTag;
- (void)setGenericTag:(NNTag*)aTag;

- (void)setRating:(float)aRating;

@end