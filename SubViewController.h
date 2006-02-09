/* SubViewController */

#import <Cocoa/Cocoa.h>

// This class keeps track of the nib's being loaded in for the Tab View
@interface SubViewController : NSObject
{
    IBOutlet NSView * 	view;
    id 			_owner;
}
@end
