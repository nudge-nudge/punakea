/* PATagButtonCell */

#import <Cocoa/Cocoa.h>
#import "PATag.h"

/**
cell for the tagcloud, displays the given tag and interacts with the user
 */
@interface PATagButtonCell : NSButtonCell
{
	PATag *fileTag;
}

- (id)initWithTag:(PATag*)aTag attributes:(NSDictionary*)attributes;

- (PATag*)fileTag;
- (void)setFileTag:(PATag*)aTag;

@end
