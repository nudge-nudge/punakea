/* PATagButton */

#import <Cocoa/Cocoa.h>
#import "PATag.h"
#import "PATagButtonCell.h"

@interface PATagButton : NSControl

- (id)initWithFrame:(NSRect)frame Tag:(PATag*)tag;

- (PATag*)fileTag;
- (void)setFileTag:(PATag*)aTag;

@end
