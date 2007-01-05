/* PATagButton */

#import <Cocoa/Cocoa.h>
#import "PATagging/PATag.h"
#import "PAButton.h"
#import "PATagButtonCell.h"
#import "PADropManager.h"

@interface PATagButton : PAButton {
	PADropManager			*dropManager;		
}

- (id)initWithTag:(PATag*)tag rating:(float)rating;

- (PATag*)genericTag;
- (void)setGenericTag:(PATag*)aTag;

- (void)setRating:(float)aRating;

@end