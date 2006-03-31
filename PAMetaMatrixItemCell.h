#import <Cocoa/Cocoa.h>

@interface PAFileMatrixItemCell : NSActionCell
{
	NSString *identifier;
	NSMetadataItem *metadataItem;
}

- (NSString*)identifier;

@end
