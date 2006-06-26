//
//  PASidebar.m
//  punakea
//
//  Created by Johannes Hoffart on 26.06.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PASidebar.h"


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
	
    return self;
}

- (void)awakeFromNib
{
	// add tracking reckt for mouse enter and exit events
	NSView *contentView = [self contentView];
	[contentView addTrackingRect:[contentView bounds] owner:self userData:NULL assumeInside:NO];

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *appearance = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:@"Appearance"]];
	
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
}

#pragma mark events
- (void)mouseEntered:(NSEvent *)theEvent {
	//TODO redirect
	NSLog(@"enter");
	NSRect newRect = [self frame];
	newRect.origin.x = newRect.origin.x - NSWidth(newRect) + 1;
	[self setFrame:newRect display:YES animate:YES];
}

- (void)mouseExited:(NSEvent *)theEvent {
	//TODO redirect
	NSLog(@"exit");
	NSRect newRect = [self frame];
	newRect.origin.x = newRect.origin.x + NSWidth(newRect) - 1;
	[self setFrame:newRect display:YES animate:YES];
}

@end
