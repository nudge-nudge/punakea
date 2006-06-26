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
	
	// DEBUG
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notification:)
                                                 name:0
                                               object:nil];
    return self;
}

- (void)notification:(NSNotification *)note
{
	//NSLog(@"%@",note);
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
}

- (void)recede
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
}
@end
