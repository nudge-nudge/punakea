/* PATagButton */

#import <Cocoa/Cocoa.h>
#import "PATag.h"
#import "PATagButtonCell.h"

@interface PATagButton : NSButton

- (id)initWithFrame:(NSRect)frame Tag:(PATag*)tag;

- (PATag*)tag;
- (void)setFileTag:(PATag*)aTag;

@end
