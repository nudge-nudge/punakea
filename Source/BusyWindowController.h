//
//  BusyWindowController.h
//  punakea
//
//  Created by Daniel on 30.01.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BusyWindowController : NSWindowController {

	IBOutlet NSProgressIndicator		*progressIndicator;
	IBOutlet NSTextField				*textField;
	
	NSString							*message;
	
	SEL									busySelector;
	id									busyObject;
	id									busyArg;
	
}

- (void)setMessage:(NSString *)aMessage;
- (void)performBusySelector:(SEL)aSelector onObject:(id)anObject;
- (void)performBusySelector:(SEL)aSelector onObject:(id)anObject withObject:(id)arg;

@end
