//
//  PASelectedTagsView.m
//  punakea
//
//  Created by Johannes Hoffart on 31.03.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PASelectedTagsView.h"


@interface PASelectedTagsView (PrivateAPI)

- (void)drawBorder;
- (void)updateView;

@end


NSSize const PADDING = {10, 7};
NSSize const INTERCELL_SPACING = {3, 3};
int const PADDING_TO_RIGHT = 100;


@implementation PASelectedTagsView

#pragma mark Init + Dealloc
- (id)initWithFrame:(NSRect)frame 
{
    if(self = [super initWithFrame:frame])
	{		
		tagButtons = [[NSMutableDictionary alloc] init];
    }
    return self;
}


- (void)awakeFromNib
{
	selectedTags = [controller selectedTags];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTagButtons:) name:@"PASelectedTagsHaveChanged" object:selectedTags];
	
	// Get notification frameDidChange
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self
	       selector:@selector(frameDidChange:)
		       name:(id)NSViewFrameDidChangeNotification
			 object:self];
			 
	// Get notification frameDidChange of SuperView!!
	[nc addObserver:self
	       selector:@selector(frameDidChange:)
		       name:(id)NSViewFrameDidChangeNotification
			 object:[self superview]];
			 
	[self addHomeButton];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[tagButtons release];
	[super dealloc];
}


#pragma mark Drawing
- (void)drawRect:(NSRect)rect 
{
	// Draw background
	[[NSColor colorWithDeviceRed:(236.0/255.0) green:(242.0/255.0) blue:(251.0/255.0) alpha:1.0] set];
	NSRectFill([self bounds]);

	// Draw top and bottom borders
	NSRect bounds = [self bounds];	
	
	
	NSBezierPath *path = [NSBezierPath bezierPath];
	[path moveToPoint:NSMakePoint(0, bounds.size.height)];
	[path lineToPoint:NSMakePoint(bounds.size.width, bounds.size.height)];
	[path closePath];
	[[NSColor grayColor] set];	
	[path stroke];
	
	/*
	path = [NSBezierPath bezierPath];
	[path moveToPoint:NSMakePoint(0, 0)];
	[path lineToPoint:NSMakePoint(bounds.size.width, 0)];
	[path closePath];
	[[NSColor lightGrayColor] set];	
	[path stroke];
	 */
	 
	[super drawRect:rect];
}

- (void)updateTagButtons:(NSNotification *)notification
{ 	
	// Reset frame
	NSRect frame = [self frame];
	frame.size.height = 40.0;

	// Remove all old tags
	NSArray *tagButtonKeys = [tagButtons allKeys];
	
	for(unsigned i = 0; i < [tagButtonKeys count]; i++)
	{
		NSString *tagName = [tagButtonKeys objectAtIndex:i];		
		PATag *tag = [[PATagger sharedInstance] tagForName:tagName];
		
		if(![selectedTags containsTag:tag])
		{
			[[tagButtons objectForKey:tagName] removeFromSuperview];
			[tagButtons removeObjectForKey:tagName];
		}
	}
	
	
	// Add or update tags
	int x = PADDING.width;
	int y = PADDING.height;
	
	int numberOfRows = 1;
	NSSize buttonSize = NSMakeSize(0, 0);

	NSEnumerator *enumerator = [selectedTags objectEnumerator];
	
	PATag *tag;
	while(tag = [enumerator nextObject])
	{			
		PAButton *button;
		
		if(!(button = [tagButtons objectForKey:[tag name]]))
		{	
			button = [[PAButton alloc] initWithFrame:[self frame]];
			[button setTitle:[tag name]];
			[button setBezelStyle:PATagBezelStyle];
			[button setShowsCloseIcon:YES];
			[button setTarget:self];
			[button setAction:@selector(tagClicked:)];
			[button setCloseAction:@selector(tagClosed:)];
			[button highlight:YES];
			[button sizeToFit];
			
			[tagButtons setObject:button forKey:[tag name]];
			
			[self addSubview:button];
		}
		
		NSRect buttonFrame = [button frame];
		
		if(buttonSize.height == 0) buttonSize = buttonFrame.size;
		
		if(x + buttonFrame.size.width + INTERCELL_SPACING.width + PADDING_TO_RIGHT > frame.size.width)
		{
			// Wrap items to new row
			x = PADDING.width;
			y += buttonFrame.size.height + INTERCELL_SPACING.height;
			
			numberOfRows++;
		}
		
		NSRect newFrame = NSMakeRect(x, y, buttonFrame.size.width, buttonFrame.size.height);
		
		[button setFrame:newFrame];
		
		x += buttonFrame.size.width + INTERCELL_SPACING.width;
	}
	
	float height = numberOfRows * (buttonSize.height + INTERCELL_SPACING.height) + 2 * PADDING.height;
	if(height < frame.size.height) height = frame.size.height;
	[self setFrameHeight:height];
}

- (void)setFrameHeight:(float)height
{
	ignoreFrameDidChange = YES;
	
	NSRect superviewFrame = [[self superview] frame];
	NSRect frame = [self frame];
	
	// Break if frame height wasn't changed
	/*if(frame.size.height == height)
	{
		ignoreFrameDidChange = NO;
		return;
	}*/
	
	frame.origin.y = superviewFrame.size.height - height;
	frame.size.height = height;
	[self setFrame:frame];
	
	NSRect fsFrame = [filterSlice frame];
	fsFrame.origin.y = frame.origin.y - fsFrame.size.height;
	[filterSlice setFrame:fsFrame];
	
	NSView *scrollView = [[outlineView superview] superview];
	NSRect svFrame = [scrollView frame];
	svFrame.size.height = fsFrame.origin.y;
	[scrollView setFrame:svFrame];	
	
	[[self superview] setNeedsDisplay:YES];
	[filterSlice setNeedsDisplay:YES];
	[scrollView setNeedsDisplay:YES];
	[self setNeedsDisplay:YES];
	
	ignoreFrameDidChange = NO;
}	


#pragma mark Actions
- (void)addHomeButton
{
	NSRect frame = [self frame];

	NSRect rect;
	rect.origin.x = frame.size.width - 50;
	rect.origin.y = 4;
	rect.size.width = 32;
	rect.size.height = 32;

	homeButton = [[PAImageButton alloc] initWithFrame:rect];
	[homeButton setImage:[NSImage imageNamed:@"home.tif"] forState:PAOffState];
	[homeButton setImage:[NSImage imageNamed:@"home_pressed.tif"] forState:PAOnState];
	
	[homeButton setTarget:controller];
	[homeButton setAction:@selector(clearSelectedTags:)];
	
	[self addSubview:homeButton];
}

- (void)tagClicked:(id)sender
{
	// nothing yet
}

- (void)tagClosed:(id)sender
{
	[selectedTags removeTag:[[PATagger sharedInstance] tagForName:[sender title]]];
}


#pragma mark Notifications
- (void)frameDidChange:(NSNotification *)notification
{
	if(!ignoreFrameDidChange) [self updateTagButtons:notification];
	
	// Update home button's frame
	NSRect frame = [self frame];
	NSRect rect;
	rect.origin.x = frame.size.width - 50;
	rect.origin.y = 4;
	rect.size.width = 32;
	rect.size.height = 32;
	
	if(homeButton) [homeButton setFrame:rect];
}


#pragma mark Accessors
- (BOOL)isFlipped
{
	return YES;
}

@end
