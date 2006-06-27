//
//  PABrowserWindow.m
//  punakea
//
//  Created by Johannes Hoffart on 27.06.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PABrowserWindow.h"


@implementation PABrowserWindow

- (void)keyDown:(NSEvent*)event
{
	if ([[self delegate] respondsToSelector:@selector(keyDown:)])
	{
		[[self delegate] keyDown:event];
	}
}

@end
