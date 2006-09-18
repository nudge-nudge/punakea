//
//  PAFinderFieldEditor.m
//  punakea
//
//  Created by Daniel on 17.09.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAFinderFieldEditor.h"


@implementation PAFinderFieldEditor

#pragma mark Init + Dealloc
- (id)initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
	if(self)
	{
		// Nothing yet
	}
	return self;
}

- (void)dealloc
{
	[self removeFromSuperview];
	[super dealloc];
}

- (BOOL)becomeFirstResponder
{
	focused = YES;
	
	[NSGraphicsContext saveGraphicsState];
		NSSetFocusRingStyle (NSFocusRingOnly);
		[[NSBezierPath bezierPathWithRect:[self frame]] fill];
		[NSGraphicsContext restoreGraphicsState];
	
	return YES;
}

- (BOOL)resignFirstResponder
{
	focused = NO;
	[self setNeedsDisplay:YES];
	return YES;
}


#pragma mark Drawing
- (void)drawRect:(NSRect)rect
{
	[super drawRect:rect];

	// Draw focus ring
	if (focused && [[self window] isKeyWindow])
	{
		
	}
}

@end
