#import <Cocoa/Cocoa.h>

@interface PAMetaMatrixItemCell : NSActionCell
{
	NSString *identifier;
	NSMetadataItem *metadataItem;
}

- (NSString*)identifier;

@end
