//
//  PAViewController.h
//  punakea
//
//  Created by Johannes Hoffart on 13.07.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
used for views just as nswindowcontroller is used for windows.
 nib loading must be done by subclasses, else the init/awakeFromNib order gets screwed.
 this means the viewController only holds an outlet to a view.
 abstract class
 */
@interface PAViewController : NSResponder {
	IBOutlet NSView *view; /**< controlled view */
}

// accessors
- (NSView*)view;
- (void)setMainView:(NSView*)aView;

@end
