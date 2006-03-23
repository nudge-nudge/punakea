//
//  PAImageButtonCell.m
//  punakea
//
//  Created by Daniel on 21.03.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAImageButtonCell.h"


@implementation PAImageButtonCell

- (id)initImageCell:(NSImage *)anImage
{	
	images = [[NSMutableDictionary alloc] init];
	if (anImage)
	{
		[self setImage:anImage forState:(id)PAOffState];
	}
	return [super initImageCell:anImage];
}

- (void)setImage:(NSImage *)image forState:(id)state
{
	[images setObject:image forKey:[NSNumber numberWithInt:state]];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	//NSImage *image = [images objectForKey:[NSNumber numberWithInt:PAOffState]];
	NSImage *image = [NSImage imageNamed:@"MDIconViewOff-1"];
	
	NSRect imageRect;
	imageRect.origin = NSZeroPoint;
	imageRect.size = [image size];
	
	[image drawAtPoint:NSZeroPoint fromRect:imageRect operation:NSCompositeSourceOver fraction:1.0];
}

- (void)dealloc
{
	if(images) { [images release]; }
	[super dealloc];
}

@end
