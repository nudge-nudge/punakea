//
//  SubViewController.h
//  punakea
//
//  Created by Johannes Hoffart on 04.07.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// This class keeps track of the nib's being loaded in for the Tab View
@interface PASubViewController : NSObject
{
    IBOutlet NSView *view;
}

-(id)initWithNibName:(NSString*)nibName;

- (NSView*)view;
@end

