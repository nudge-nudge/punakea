// Copyright (c) 2006-2012 nudge:nudge (Johannes Hoffart & Daniel BŠr). All rights reserved.
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

#import "PAResultsMultiItemGenericCell.h"


@implementation PAResultsMultiItemGenericCell

#pragma mark Init + Dealloc
- (id)initTextCell:(NNTaggableObject *)anItem
{
	self = [super initTextCell:@""];
	if (self)
	{
		item = [anItem retain];	
	}	
	return self;
}

- (void)dealloc
{
	if(item) [item release];
	[super dealloc];
}


#pragma mark Class methods
+ (NSSize)cellSize
{
	return NSMakeSize(0, 0);
}

+ (NSSize)intercellSpacing
{
	return NSMakeSize(0, 0);
}


#pragma mark Accessors
- (NNFile *)item
{
	return item;
}

- (void)setItem:(NNFile *)anItem
{
	if(item) [item release];
	item = [anItem retain];
}

@end
