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

#import "PAStatusBarProgressIndicator.h"


CGFloat const STATUSBAR_PROGRESS_INDICATOR_SPACING = 7.0;
CGFloat const STATUSBAR_PROGRESS_INDICATOR_MIN_WIDTH = 60.0;
NSSize const STATUSBAR_PROGRESS_INDICATOR_PADDING = {5.0, 0.0};


@implementation PAStatusBarProgressIndicator

#pragma mark Init + Dealloc
- (id)initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
	if(self)
	{
		NSRect piRect = [self bounds];
		piRect.size.width = STATUSBAR_PROGRESS_INDICATOR_MIN_WIDTH;
		
		progressIndicator = [[NSProgressIndicator alloc] initWithFrame:piRect];
		[progressIndicator setStyle:NSProgressIndicatorBarStyle];
		[self setControlSize:NSSmallControlSize];
		
		// By now we only support indeterminate indicators ;)
		[progressIndicator setIndeterminate:YES];
		
		[progressIndicator setDisplayedWhenStopped:NO];
		[progressIndicator setUsesThreadedAnimation:YES];
		[progressIndicator startAnimation:self];
		
		[self setAlignment:NSRightTextAlignment];
	}	
	return self;
}

+ (PAStatusBarProgressIndicator *)statusBarProgressIndicator
{
	return [[[self alloc] initWithFrame:NSMakeRect(0, 0, STATUSBAR_BUTTON_MIN_SIZE.width, STATUSBAR_BUTTON_MIN_SIZE.height)] autorelease];
}

- (void)dealloc
{
	[progressIndicator removeFromSuperviewWithoutNeedingDisplay];
	[progressIndicator release];
	
	if(stringValue) [stringValue release];
	if(identifier) [identifier release];
	
	[super dealloc];
}


#pragma mark Drawing
- (void)drawRect:(NSRect)aRect
{
	// Check on string value
	if([self stringValue])
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
		rect.origin.x = STATUSBAR_PROGRESS_INDICATOR_PADDING.width;
		rect.origin.y = ([self bounds].size.height - rect.size.height) / 2.0;
		
		[attrStr drawInRect:rect];
	}
		
	
	// Check on progress indicator as subview
	if([progressIndicator superview] != self)
		[self addSubview:progressIndicator];
	
	// Adjust frame of progress indicator
	NSRect piRect = [progressIndicator frame];	
	piRect.origin.x = [self bounds].size.width - piRect.size.width - STATUSBAR_PROGRESS_INDICATOR_PADDING.width;
	piRect.origin.y = abs(([self bounds].size.height - piRect.size.height) / 2.0);
	
	[progressIndicator setFrame:piRect];
}


#pragma mark Misc
- (void)sizeToFit
{
	// Resize progress indicator
	[progressIndicator sizeToFit];
	
	// Resize to fit string value's width
	if([self stringValue])
	{
		NSFont *font = [NSFont systemFontOfSize:11.0];
		
		NSMutableDictionary *fontAttributes = [NSMutableDictionary dictionaryWithCapacity:1];	
		[fontAttributes setObject:font forKey:NSFontAttributeName];
		
		NSAttributedString *attrStr = [[[NSAttributedString alloc] initWithString:[self stringValue]
																	   attributes:fontAttributes] autorelease];
		
		NSRect newFrame = [self frame];
		newFrame.size.width = [attrStr size].width + 
			STATUSBAR_PROGRESS_INDICATOR_SPACING +
			STATUSBAR_PROGRESS_INDICATOR_PADDING.width * 2 +
			[progressIndicator frame].size.width;
		
		[self setFrame:newFrame];
	}
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

- (NSControlSize)controlSize
{
	return [progressIndicator controlSize];
}

- (void)setControlSize:(NSControlSize)size
{
	[progressIndicator setControlSize:size];
	[self sizeToFit];
}

- (NSProgressIndicatorStyle)style
{
	return [progressIndicator style];
}

- (void)setStyle:(NSProgressIndicatorStyle)style
{
	[progressIndicator setStyle:style];
	[self sizeToFit];
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
