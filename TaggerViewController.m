#import "TaggerViewController.h"

@implementation TaggerViewController

- (void)awakeFromNib {
	tagger = [PATagger sharedInstance];
}

- (IBAction)setTagsForFile:(id)sender {
	NSArray* tags = [tagController selectedObjects];

	NSEnumerator *e = [tags objectEnumerator];
	PATag *tag;
	
	while (tag = [e nextObject])
		[tag incrementUseCount];	
	
	NSLog(@"trying to write %@ to %@",tags,[filePath stringValue]);
	[tagger writeTagsToFile:tags filePath:[filePath stringValue]];
}

@end
