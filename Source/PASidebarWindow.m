//
//  PASidebar.m
//  punakea
//
//  Created by Johannes Hoffart on 26.06.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PASidebarWindow.h"

@interface PASidebarWindow (PrivateAPI)

- (void)show;
- (void)show:(BOOL)animate;
- (void)recede;
- (void)recede:(BOOL)animate;

@end

@implementation PASidebarWindow

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
	[self setDelegate:self];
	
	// add tracking reckt for mouse enter and exit events
	NSView *contentView = [self contentView];
	[contentView addTrackingRect:[contentView bounds] owner:self userData:NULL assumeInside:NO];
	
	// move to screen edge - according to prefs
	[self setExpanded:YES];
	[self recede:NO];
	
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


#pragma mark functionality
- (void)show
{
	[self show:YES];
}

- (void)recede
{
	[self recede:YES];
}

- (void)show:(BOOL)animate
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
		[self setFrame:newRect display:YES animate:animate];
		[self setExpanded:YES];
	}	
}

- (void)recede:(BOOL)animate
{
	if ([self isExpanded])
	{
		NSRect newRect = [self frame];
		NSRect screenRect = [[NSScreen mainScreen] frame];

		if ([[appearance objectForKey:@"SidebarPosition"] isEqualToString:@"LEFT"])
		{
			newRect.origin.x = 0 - newRect.size.width + 1;
		}
		else
		{
			newRect.origin.x = screenRect.size.width - 1;
		}
		
		newRect.origin.y = screenRect.size.height/2 - newRect.size.height/2;
		[self setFrame:newRect display:YES animate:animate];
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
