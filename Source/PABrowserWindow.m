//
//  PABrowserWindow.m
//  punakea
//
//  Created by Daniel on 28.04.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PABrowserWindow.h"


@implementation PABrowserWindow

- (void)flagsChanged:(NSEvent *)theEvent
{
	// As event messages are not forwarded to the delegate by default, we need to
	// do this manually to get the option key working like in iTunes
	
	if([self delegate] && [[self delegate] respondsToSelector:@selector(flagsChanged:)])
	{
		[[self delegate] flagsChanged:theEvent];
	}
}

@end
