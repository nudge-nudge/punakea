#import "TaggerViewController.h"

@implementation TaggerViewController

- (void)awakeFromNib {
	tagger = [PATagger sharedInstance];
}

- (IBAction)setTagsForFile:(id)sender {
	NSArray* tags = [tagController selectedObjects];
	
	NSLog(@"trying to write %@ to %@",tags,[filePath stringValue]);
	[tagger writeTagsToFile:tags filePath:[filePath stringValue]];
}

@end
