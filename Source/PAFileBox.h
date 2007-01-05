/* PAFileBox */

#import <Cocoa/Cocoa.h>
#import "PATagging/PATag.h"
#import "PADropManager.h"

@interface PAFileBox : NSImageView
{
	NSMutableArray *objects;
	
	PADropManager *dropManager;
}

- (void)setObjects:(NSArray*)objectArray;
- (NSMutableArray*)objects;

@end
