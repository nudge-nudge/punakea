// Copyright (c) 2006-2012 nudge:nudge (Johannes Hoffart & Daniel Bär). All rights reserved.
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "PAStatusBarLink.h"



NSSize const STATUSBAR_LINK_PADDING = {10.0, 0.0};
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
	NSColor *color = [NSColor colorWithCalibratedWhite:0.2 alpha:1.0];			
	NSFont *font = [NSFont systemFontOfSize:11.0];
	
	NSMutableDictionary *fontAttributes = [NSMutableDictionary dictionaryWithCapacity:3];	
	[fontAttributes setObject:color forKey:NSForegroundColorAttributeName];
	[fontAttributes setObject:font forKey:NSFontAttributeName];
	
	// Underline only if there's an action present
	if ([self action])
	{
		[fontAttributes setObject:[NSNumber numberWithInteger:NSUnderlineStyleSingle]
						   forKey:NSUnderlineStyleAttributeName];
	}
	
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


#pragma mark Events
- (void)mouseUp:(NSEvent *)event
{
	[[self target] performSelector:[self action]];
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

- (id)target
{
	return target;
}

- (void)setTarget:(id)aTarget
{
	// Weak reference
	target = aTarget;
}

- (SEL)action
{
	return action;
}

- (void)setAction:(SEL)selector
{
	action = selector;
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
