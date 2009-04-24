//
//  PAStatusBarLink.m
//  punakea
//
//  Created by Daniel on 21.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PAStatusBarLink.h"



NSSize const STATUSBAR_LINK_PADDING = {5.0, 0.0};
NSSize const STATUSBAR_LINK_MIN_SIZE = {0.0, 22};


@implementation PAStatusBarLink

#pragma mark Init + Dealloc
+ (PAStatusBarLink *)statusBarLink
{
	return [[[self alloc] initWithFrame:NSMakeRect(0, 0, STATUSBAR_LINK_MIN_SIZE.width, STATUSBAR_LINK_MIN_SIZE.height)] autorelease];
}

- (id)initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
	if(self)
	{
		[self setAlignment:NSRightTextAlignment];
	}	
	return self;
}

- (void)dealloc
{
	[stringValue release];
	
	[super dealloc];
}


#pragma mark Drawing
- (void)drawRect:(NSRect)aRect
{
	NSColor *color = [NSColor colorWithCalibratedWhite:0.05 alpha:1.0];		
	
	NSFont *font = [NSFont systemFontOfSize:11.0];
	
	NSMutableDictionary *fontAttributes = [NSMutableDictionary dictionaryWithCapacity:3];	
	[fontAttributes setObject:color forKey:NSForegroundColorAttributeName];
	[fontAttributes setObject:font forKey:NSFontAttributeName];
	
	NSAttributedString *attrStr = [[[NSAttributedString alloc] initWithString:[self stringValue]
																   attributes:fontAttributes] autorelease];
	
	// Rect for string value
	NSRect rect = [self bounds];
	rect.size.width = [attrStr size].width;
	rect.size.height = [attrStr size].height;
	rect.origin.x = STATUSBAR_LINK_PADDING.width;
	rect.origin.y = ([self bounds].size.height - rect.size.height) / 2.0;
	
	[attrStr drawInRect:rect];	
}


#pragma mark Misc
- (void)sizeToFit
{
	NSFont *font = [NSFont systemFontOfSize:11.0];
	
	NSMutableDictionary *fontAttributes = [NSMutableDictionary dictionaryWithCapacity:1];	
	[fontAttributes setObject:font forKey:NSFontAttributeName];
	
	NSAttributedString *attrStr = [[[NSAttributedString alloc] initWithString:[self stringValue]
																   attributes:fontAttributes] autorelease];
	
	NSRect newFrame = [self frame];
	newFrame.size.width = [attrStr size].width + STATUSBAR_LINK_PADDING.width * 2;
	
	[self setFrame:newFrame];
}


#pragma mark Accessors
- (PAStatusBar *)statusBar
{
	return statusBar;
}

-(void)setStatusBar:(PAStatusBar *)sb
{
	statusBar = sb;
}

- (NSString *)identifier
{
	return identifier;
}

- (void)setIdentifier:(NSString *)anIdentifier
{
	[identifier release];
	identifier = [anIdentifier retain];
}

- (NSString *)stringValue
{
	return stringValue;
}

- (void)setStringValue:(NSString *)aString
{
	[stringValue release];
	stringValue = [aString retain];
	
	[self sizeToFit];
	[[self superview] updateItems];
}

- (NSTextAlignment)alignment
{
	return alignment;
}

- (void)setAlignment:(NSTextAlignment)mode
{
	alignment = mode;
}

@end
