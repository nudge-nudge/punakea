//
//  PASidebar.m
//  punakea
//
//  Created by Johannes Hoffart on 26.06.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PASidebar.h"

@interface PASidebar (PrivateAPI)

- (void)show;
- (void)recede;

@end

@implementation PASidebar

#pragma mark init and dealloc
- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
    /* Enforce borderless window; allows us to handle dragging ourselves */
    self = [super initWithContentRect:contentRect
                            styleMask:NSBorderlessWindowMask
                              backing:bufferingType defer:flag];
	
    [self setLevel: NSStatusWindowLevel];
	[self setAcceptsMouseMovedEvents:YES];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    appearance = [[NSMutableDictionary alloc] initWithDictionary:[defaults objectForKey:@"Appearance"]];
	
    return self;
}

- (void)awakeFromNib
{
	// add tracking reckt for mouse enter and exit events
	NSView *contentView = [self contentView];
	[contentView addTrackingRect:[contentView bounds] owner:self userData:NULL assumeInside:NO];
	
	// move sidebar to screen edge - according to prefs
	NSRect screenRect = [[NSScreen mainScreen] frame];
	NSRect newRect = [self frame];
	
	if ([[appearance objectForKey:@"SidebarPosition"] isEqualToString:@"LEFT"]) 
	{
		newRect.origin.x = 0 - newRect.size.width + 1;
	}
	else
	{
		// default position on the right side
		newRect.origin.x = screenRect.size.width - 1;
	}
	
	newRect.origin.y = screenRect.size.height/2 - newRect.size.height/2;
	[self setFrameOrigin:newRect.origin];
	
	[self setExpanded:NO];
}

- (void)dealloc
{
	[appearance release];
	[super dealloc];
}

#pragma mark events
- (void)mouseEntered:(NSEvent *)theEvent 
{
	NSLog(@"enter");
	[self show];
}

- (void)mouseExited:(NSEvent *)theEvent 
{
	NSLog(@"exit");
	[self recede];
}

- (void)show
{
	if (![self isExpanded]) 
	{
		NSRect newRect = [self frame];
		if ([[appearance objectForKey:@"SidebarPosition"] isEqualToString:@"LEFT"])
		{
			newRect.origin.x = 0;
		}
		else
		{
			newRect.origin.x = newRect.origin.x - newRect.size.width + 1;
		}
		[self setFrame:newRect display:YES animate:YES];
		[self setExpanded:YES];
	}
}

- (void)recede
{
	if ([self isExpanded])
	{
		NSRect newRect = [self frame];
		if ([[appearance objectForKey:@"SidebarPosition"] isEqualToString:@"LEFT"])
		{
			newRect.origin.x = 0 - newRect.size.width + 1;
		}
		else
		{
			newRect.origin.x = newRect.origin.x + newRect.size.width - 1;
		}	
		[self setFrame:newRect display:YES animate:YES];
		[self setExpanded:NO];
	}
}

#pragma mark accessors
- (BOOL)isExpanded 
{
	return expanded;
}

- (void)setExpanded:(BOOL)flag 
{
	expanded = flag;
}

@end
