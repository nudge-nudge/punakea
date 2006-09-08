/* PAFileBox */

#import <Cocoa/Cocoa.h>
#import "PATagger.h"
#import "PATag.h"
#import "PADropManager.h"

@interface PAFileBox : NSImageView
{
	NSMutableArray *files;
	NSImage *fileIcon;
	BOOL highlight;
	
	PADropManager *dropManager;
}

- (void)setFiles:(NSMutableArray*)fileArray;
- (NSMutableArray*)files;
- (void)setFileIcon:(NSImage*)newIcon;
- (NSImage*)fileIcon;

@end
