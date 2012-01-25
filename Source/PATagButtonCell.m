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

#import "PATagButtonCell.h"

NSInteger const MIN_FONT_SIZE = 12;
NSInteger const MAX_FONT_SIZE = 25;

@interface PATagButtonCell (PrivateAPI)

- (void)drawHoverEffectWithFrame:(NSRect)cellFrame;
- (void)buildTitle;

@end

@implementation PATagButtonCell

#pragma mark init
- (id)initWithTag:(NNTag*)aTag rating:(CGFloat)aRating
{
	if (self = [super initTextCell:[aTag name]])
	{
		[self setAction:@selector(tagButtonClicked:)];
		[self setGenericTag:aTag];
		[self setRating:aRating];
	}
	return self;
}

- (void)dealloc
{
	[genericTag release];
	[super dealloc];
}

#pragma mark Misc
- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView untilMouseUp:(BOOL)untilMouseUp
{
	// Disable mouse tracking to let our button handle the dragging
	return NO;
}

#pragma mark accessors
- (NNTag*)genericTag
{
	return genericTag;
}

- (void)setGenericTag:(NNTag*)aTag
{
	[aTag retain];
	[genericTag release];
	genericTag = aTag;
}

- (CGFloat)rating
{
	return rating;
}

- (void)setRating:(CGFloat)aRating
{
	rating = aRating;
	
	NSInteger newFontSize = MAX_FONT_SIZE * [self rating];
	if (newFontSize < MIN_FONT_SIZE)
		newFontSize = MIN_FONT_SIZE;
	
	[self setFontSize:newFontSize];
}

@end
