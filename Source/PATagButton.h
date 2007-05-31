/* PATagButton */

#import <Cocoa/Cocoa.h>
#import "NNTagging/NNTag.h"
#import "NNTagging/NNTaggableObject.h"
#import "PAButton.h"
#import "PATagButtonCell.h"
#import "PADropManager.h"
#import "PASmartFolder.h"

@interface PATagButton : PAButton {
	PADropManager			*dropManager;		
}

- (id)initWithTag:(NNTag*)tag rating:(float)rating;

// TODO: Why is this called genericTag, not just tag?! --daniel
// TODO: Because every NSControl has a tag accessor already, that's why your tag accessors give warnings! --johannes
- (NNTag*)genericTag;
- (void)setGenericTag:(NNTag*)aTag;

- (void)setRating:(float)aRating;

@end