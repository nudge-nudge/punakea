/* PAFileBox */

#import <Cocoa/Cocoa.h>
#import "PATagger.h"
#import "PATag.h"

@interface PAFileBox : NSImageView
{
	NSMutableArray *files;
	NSImage *fileIcon;
	BOOL highlight;
}

- (void)setFiles:(NSMutableArray*)fileArray;
- (NSMutableArray*)files;
- (void)setFileIcon:(NSImage*)newIcon;
- (NSImage*)fileIcon;

@end
