#import <Cocoa/Cocoa.h>
#import "PAImageButton.h"

@interface PAFileMatrixGroupCell : NSActionCell
{
	NSString *identifier;
	bool isExpanded;
	PAImageButton *triangle;
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
- (id)initTextCell:(NSString*)aText;

- (void)toggle;
- (void)expand;
- (void)collapse;

- (NSString*)identifier;
- (bool)isExpanded;
@end
