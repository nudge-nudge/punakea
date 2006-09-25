//
//  PAViewController.h
//  punakea
//
//  Created by Johannes Hoffart on 13.07.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PAViewController : NSResponder {
	IBOutlet NSView *mainView;
}

// accessors
- (NSView*)mainView;
- (void)setMainView:(NSView*)aView;

@end
