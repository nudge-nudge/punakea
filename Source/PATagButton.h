/* PATagButton */

#import <Cocoa/Cocoa.h>
#import "PATag.h"
#import "PAButton.h"
#import "PATagButtonCell.h"
#import "PADropManager.h"
#import "PATagger.h"

@interface PATagButton : PAButton {
	PADropManager *dropManager;
	PATagger *tagger;
}

- (id)initWithTag:(PATag*)tag rating:(float)rating;

- (PATag*)fileTag;
- (void)setFileTag:(PATag*)aTag;

- (void)setRating:(float)aRating;

@end