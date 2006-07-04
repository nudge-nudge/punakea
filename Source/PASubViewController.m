//
//  SubViewController.m
//  punakea
//
//  Created by Johannes Hoffart on 04.07.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PASubViewController.h"

@implementation PASubViewController

// This method initializes a new instance of this class which loads in nibs and facilitates the communcation between the nib and the controller of the main window.
-(id)initWithNibName:(NSString*)nibName 
{
    if (self = [super init])
	{
		[NSBundle loadNibNamed:nibName owner:self];
	}
    return self;
}

// This method releases the pointer to the view in the nib.
- (void)dealloc
{
    [super dealloc];
    [view release];
}

// This method returns a pointer to the view in the nib loaded.
-(NSView*)view
{
	return view;
}
@end
