#import "PASelectedTagsController.h"

@implementation PASelectedTagsController

- (id)newObject {
	PATag *tag = [super newObject];
	[tag setName:@"test"];
	return tag;
}

@end
