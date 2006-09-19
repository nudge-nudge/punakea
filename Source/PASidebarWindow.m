//
//  PASidebar.m
//  punakea
//
//  Created by Johannes Hoffart on 26.06.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PASidebarWindow.h"

double const SHOW_DELAY = 0.2;

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
	
    //This next line pulls the window up to the front on top of other system windows.  This is how the Clock app behaves;
    //generally you wouldn't do this for windows unless you really wanted them to float above everything.
    [self setLevel: NSStatusWindowLevel];
    //Let's start with no transparency for all drawing into the window
    [self setAlphaValue:1.0];
    //but let's turn off opaqueness so that we can see through the parts of the window that we're not drawing into
    [self setOpaque:NO];	
	
	// This makes the window semi-transparent, but not its subviews
	[self setBackgroundColor:[NSColor colorWithDeviceRed:1.0 green:1.0 blue:1.0 alpha:0.4]];
	
	[self setAcceptsMouseMovedEvents:YES];
		
    return self;
}

- (void)awakeFromNib
{
	[self setDelegate:self];
	
	// add tracking reckt for mouse enter and exit events
	NSView *contentView = [self contentView];
	[contentView addTrackingRect:[contentView bounds] owner:self userData:NULL assumeInside:NO];
	
	[self bind:@"sidebarPosition" 
	  toObject:[NSUserDefaultsController sharedUserDefaultsController] 
   withKeyPath:@"values.Appearance.SidebarPosition" 
	   options:nil];
	
	[[NSUserDefaultsController sharedUserDefaultsController] addObserver:self 
															  forKeyPath:@"values.Appearance.SidebarPosition" 
																 options:NULL 
																 context:NULL];
	
	[self bind:@"sidebarColor"
	  toObject:[NSUserDefaultsController sharedUserDefaultsController]
   withKeyPath:@"values.Appearance.SidebarColor"
	   options:nil];
	
	[[NSUserDefaultsController sharedUserDefaultsController] addObserver:self
															  forKeyPath:@"values.Appearance.SidebarColor"
																 options:NULL
																 context:NULL];
	
	// move to screen edge - according to prefs
	[self setExpanded:YES];
	[self recede:NO];
}

- (void)dealloc
{
	[[NSUserDefaultsController sharedUserDefaultsController] removeObserver:self];
	[super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ((object == [NSUserDefaultsController sharedUserDefaultsController]) && [keyPath isEqualToString:@"values.Appearance.SidebarPosition"])
	{
		[self setExpanded:YES];
		[self recede:NO];
	}
	else if ((object == [NSUserDefaultsController sharedUserDefaultsController]) && [keyPath isEqualToString:@"values.Appearance.SidebarColor"])
	{
		[self setBackgroundColor:sidebarColor];
	}
}			

#pragma mark events
- (void)mouseEvent
{
	if (![self mouseInWindow])
	{
		[self recede];
	}
	else
	{
		[self performSelector:@selector(show) withObject:nil afterDelay:SHOW_DELAY];
	}
}

- (BOOL)mouseInWindow
{
	NSPoint mouseLocation = [self mouseLocationOutsideOfEventStream];
	NSPoint mouseLocationRelativeToWindow = [self convertBaseToScreen:mouseLocation];
	
	/* DEBUG
	 NSLog(@"mouse: (%f,%f)",mouseLocationRelativeToWindow.x,mouseLocationRelativeToWindow.y);
	 NSLog(@"frame: (%f,%f,%f,%f)",[self frame].origin.x,[self frame].origin.y,[self frame].size.width,[self frame].size.height);
	 */
	
	return (NSPointInRect(mouseLocationRelativeToWindow,[self frame]) || (mouseLocationRelativeToWindow.x == 0));
}

- (void)mouseEntered:(NSEvent *)theEvent 
{
	[self mouseEvent];
}

- (void)mouseExited:(NSEvent *)theEvent 
{
	[self mouseEvent];
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
	if (![self isExpanded] && [self mouseInWindow])
	{
		NSRect newRect = [self frame];
		
		switch (sidebarPosition)
		{
			case PASidebarPositionLeft:	
				newRect.origin.x = 0;
				break;
			case PASidebarPositionRight:
				newRect.origin.x = newRect.origin.x - newRect.size.width + 1;
				break;
		}

		[self setAlphaValue:1.0];

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

		switch (sidebarPosition)
		{
			case PASidebarPositionLeft:	
				newRect.origin.x = 0 - newRect.size.width + 1;
				break;
			case PASidebarPositionRight: 
				newRect.origin.x = screenRect.size.width - 1;
				break;
		}
		
		newRect.origin.y = screenRect.size.height/2 - newRect.size.height/2;
		[self setFrame:newRect display:YES animate:animate];
		[self setExpanded:NO];
		
		[self setAlphaValue:0.05];
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
