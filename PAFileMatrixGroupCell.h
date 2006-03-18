#import <Cocoa/Cocoa.h>

@interface PAFileMatrixGroupCell : NSActionCell
{
	NSString *key;
	bool isExpanded;
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
- (void)initTextCell:(NSString*)aText;

- (void)toggle;
- (void)expand;
- (void)collapse;

- (NSString*)key;
- (bool)isExpanded;
@end
