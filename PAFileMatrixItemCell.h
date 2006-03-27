#import <Cocoa/Cocoa.h>

@interface PAFileMatrixItemCell : NSActionCell
{
	NSString *key;
	NSMetadataItem *metadataItem;
}

- (NSString*)key;

@end
