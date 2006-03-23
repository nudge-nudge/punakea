//
//  PAImageButtonCell.m
//  punakea
//
//  Created by Daniel on 21.03.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAImageButtonCell.h"


@interface PAImageButtonCell (PrivateAPI)

- (NSString*)stringForState:(PAImageButtonState)aState;

@end


@implementation PAImageButtonCell

- (id)initImageCell:(NSImage *)anImage
{	
	self = [super initImageCell:anImage];
	
	images = [[NSMutableDictionary alloc] init];
	if (anImage)
	{
		[self setImage:anImage forState:PAOffState];
	}
	state = PAOffState;
	//[self trackMouse:(id)NSLeftMouseDown inRect:[self rect] ofView:self untilMouseUp:NO];
	
	return self;
}

- (void)setImage:(NSImage *)anImage forState:(PAImageButtonState)aState
{
	[images setObject:anImage forKey:[self stringForState:aState]];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSLog([self stringForState:state]);
	NSImage *image = [images objectForKey:[self stringForState:state]];
	
	NSRect imageRect;
	imageRect.origin = NSZeroPoint;
	imageRect.size = [image size];
	
	[image drawAtPoint:NSZeroPoint fromRect:imageRect operation:NSCompositeSourceOver fraction:1.0];
}

- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView untilMouseUp:(BOOL)untilMouseUp
{
	/*BOOL keepOn = YES;
	
	while (keepOn)
	{
		switch ([theEvent type])
		{
			case NSLeftMouseDown:
				[self setState:PAOnState];
				keepOn = NO; 
				break;
			case NSLeftMouseUp:
				[self setState:PAOffState];
				keepOn = NO;
				break;
			default:
				break;
		}
	}*/
	if ([theEvent type] == NSLeftMouseDown) { [self setState:PAOnState]; }
	
	return YES;
}

- (void)stopTracking:(NSPoint)lastPoint at:(NSPoint)stopPoint inView:(NSView *)controlView mouseIsUp:(BOOL)flag
{
	[self setState:PAOffState];
}

- (void)setButtonType:(NSButtonType)aType
{
	type = aType;
}

- (NSString*)stringForState:(PAImageButtonState)aState
{
	NSString *name;
	if(aState == PAOnState) { name = @"PAOnState"; }
	if(aState == PAOffState) { name = @"PAOffState"; }
	// TODO: Add all states!
	return name;
}

- (void)setState:(PAImageButtonState)aState
{
	state = aState;
}

- (void)dealloc
{
	if(images) { [images release]; }
	[super dealloc];
}

@end
