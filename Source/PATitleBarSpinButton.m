//
//  PATitleBarSpinButton.m
//  punakea
//
//  Created by Daniel Bär on 18.12.11.
//  Copyright 2012 nudge:nudge. All rights reserved.
//

#import "PATitleBarSpinButton.h"

@implementation PATitleBarSpinButton

#pragma mark Init + Dealloc
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
	{		
		// Use an own cell
		PATitleBarSpinButtonCell *cell = [[PATitleBarSpinButtonCell alloc] initImageCell:nil];
		[self setCell:cell];
		[cell release];
		
		// Say we want a drawing layer
		[self setWantsLayer:YES];
		
		// Use an NSImageView for drawing rather than drawing directly onto the view
		imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(10, 10, 20, 20)];
		[imageView setImageAlignment:NSImageAlignTopLeft];
		[imageView setImageFrameStyle:NSImageFrameNone];
		[self addSubview:imageView];
		
		// Set the anchor point for the animation to the center of the image view
		// (relative coordinates ranging from 0 to 1 in both directions)
		imageView.layer.anchorPoint = CGPointMake(0.5, 0.5);
	}
    
    return self;
}

+ (PATitleBarSpinButton *)titleBarButton
{
	return [[PATitleBarSpinButton alloc] initWithFrame:NSMakeRect(0, 0, 20, 20)];
}

- (void)dealloc
{
	[imageView release];
	[super dealloc];
}


#pragma mark Actions
- (void)start:(id)sender
{	
	if (!shouldStop)
	{
		/*CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
		[animation setDuration:1.0f];
		[animation setAutoreverses:NO];
		[animation setRepeatCount:1.0f];
		[animation setCumulative:YES];
		[animation setFromValue:[NSNumber numberWithDouble:(M_PI * 2.0f)]];	
		[animation setRemovedOnCompletion:NO];
		[animation setDelegate:self];
		[imageView.layer addAnimation:animation forKey:@"spin"];*/
	}
}

- (void)stop:(id)sender
{
	shouldStop = YES;
}


#pragma mark Animation Delegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
	if (!shouldStop)
	{
		[self start:self];
	} else {
		[[self cell] setSpinning:NO];
		shouldStop = NO;
	}
}


#pragma mark Drawing
- (void)drawImage:(NSImage *)anImage
{
	[imageView setImage:anImage];
	[imageView setNeedsDisplay:YES];
}


#pragma mark Accessors
- (NSImage *)image
{
	return [[self cell] image];
}

- (void)setImage:(NSImage *)anImage
{
	[[self cell] setImage:anImage];
}

@end
