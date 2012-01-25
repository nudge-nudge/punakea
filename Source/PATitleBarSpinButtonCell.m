//
//  PATitleBarSpinButtonCell.m
//  punakea
//
//  Created by Daniel Bär on 19.12.11.
//  Copyright 2012 nudge:nudge. All rights reserved.
//

#import "PATitleBarSpinButtonCell.h"

@implementation PATitleBarSpinButtonCell

#pragma mark Init + Dealloc
- (id)initImageCell:(NSImage *)anImage
{	
	self = [super initImageCell:anImage];
	if(self)
	{
		spinning = NO;
	}	
	return self;
}

- (void)dealloc
{
	[super dealloc];
}


#pragma mark Drawing
- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSImage *tintedImage = [self tintedImage:[[[self image] copy] autorelease] cellFrame:[[self controlView] frame]];
	[[self controlView] drawImage:tintedImage];
}


#pragma mark Actions
- (void)stopTracking:(NSPoint)lastPoint at:(NSPoint)stopPoint inView:(NSView *)controlView mouseIsUp:(BOOL)flag
{
	if (!spinning)
	{
		spinning = YES;
		[[self controlView] start:nil];
		[super stopTracking:lastPoint at:stopPoint inView:controlView mouseIsUp:flag];
	} /*else {
		// TODO Only for testing. Remove if connected to external actions.
		[[self controlView] stop:nil];
	}*/
}


#pragma mark Accessors
- (void)setSpinning:(BOOL)flag
{
	spinning = flag;
}

@end
