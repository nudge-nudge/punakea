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


@implementation PASelectedTagsView

#pragma mark Init + Dealloc
- (id)initWithFrame:(NSRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) {		
		tagButtons = [[NSMutableDictionary alloc] init];
    }
    return self;
}


- (void)awakeFromNib
{
	selectedTags = [controller selectedTags];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTagButtons:) name:@"PASelectedTagsHaveChanged" object:selectedTags];
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
	
	path = [NSBezierPath bezierPath];
	[path moveToPoint:NSMakePoint(0, 0)];
	[path lineToPoint:NSMakePoint(bounds.size.width, 0)];
	[path closePath];
	[[NSColor lightGrayColor] set];	
	[path stroke];

	[super drawRect:rect];
}

- (void)updateTagButtons:(NSNotification*)notification
{ 	
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
	int x = 10;
	int y = 7;

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
		
		NSRect newFrame = NSMakeRect(x, y, buttonFrame.size.width, buttonFrame.size.height);
		
		[button setFrame:newFrame];
		
		x += buttonFrame.size.width + 3;
	}
	
	[self setNeedsDisplay:YES];
}


#pragma mark Actions
- (void)tagClicked:(id)sender
{
	// nothing yet
}

- (void)tagClosed:(id)sender
{
	[selectedTags removeTag:[[PATagger sharedInstance] tagForName:[sender title]]];
}


#pragma mark Accessors
- (BOOL)isFlipped
{
	return YES;
}

@end
