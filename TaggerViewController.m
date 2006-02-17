#import "TaggerViewController.h"

@implementation TaggerViewController

- (void)awakeFromNib {
	ti = [[PATaggerInterface alloc] init];
}

- (IBAction)setTagsForFile:(id)sender {
	NSArray* tags = [[tagList stringValue] componentsSeparatedByString:@","];
	NSLog(@"trying to write %@ to %@",tags,[filePath stringValue]);
	[ti addTagsToFile:tags filePath:[filePath stringValue]];
}

@end
