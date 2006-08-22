/* PATagButton */

#import <Cocoa/Cocoa.h>
#import "PATag.h"
#import "PAButton.h"
#import "PATagButtonCell.h"

@interface PATagButton : PAButton

- (id)initWithTag:(PATag*)tag rating:(float)rating;

- (PATag*)fileTag;
- (void)setFileTag:(PATag*)aTag;

- (BOOL)isSelected;
- (void)setSelected:(BOOL)flag;

- (void)setRating:(float)aRating;

@end