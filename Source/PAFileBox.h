/* PAFileBox */

#import <Cocoa/Cocoa.h>
#import "PATagger.h"
#import "PATag.h"
#import "PADropManager.h"

@interface PAFileBox : NSImageView
{
	NSMutableArray *files;
	
	PADropManager *dropManager;
}

- (void)setFiles:(NSArray*)fileArray;
- (NSMutableArray*)files;

@end
