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
	return self;
}

- (void)setImage:(NSImage *)anImage forState:(PAImageButtonState)aState
{
	[images setObject:anImage forKey:[self stringForState:aState]];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSImage *image = [images objectForKey:[self stringForState:PAOffState]];
	
	NSRect imageRect;
	imageRect.origin = NSZeroPoint;
	imageRect.size = [image size];
	
	[image drawAtPoint:NSZeroPoint fromRect:imageRect operation:NSCompositeSourceOver fraction:1.0];
}

- (NSString*)stringForState:(PAImageButtonState)aState
{
	NSString *name;
	if(aState == PAOffState) { name = @"PAOffState"; }
	return name;
}

- (void)dealloc
{
	if(images) { [images release]; }
	[super dealloc];
}

@end
