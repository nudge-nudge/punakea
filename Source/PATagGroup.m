// Copyright (c) 2006-2011 nudge:nudge (Johannes Hoffart & Daniel Bär). All rights reserved.
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

#import "PATagGroup.h"

@interface PATagGroup (PrivateAPI)

- (void)setGroupedTags:(NSMutableArray*)someTags;

@end

@implementation PATagGroup

- (id)init
{
	if (self = [super init])
	{
		maxSize = 8;
		tags = [NNTags sharedTags];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tagsHaveChanged) name:nil object:tags];
	}
	
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[groupedTags release];
	[super dealloc];
}

- (NSMutableArray*)groupedTags
{
	return groupedTags;
}

- (void)setGroupedTags:(NSMutableArray*)someTags
{
	[someTags retain];
	[groupedTags release];
	groupedTags = someTags;
}

- (void)setSortDescriptors:(NSArray*)someSortDescriptors
{
	[someSortDescriptors retain];
	[sortDescriptors release];
	sortDescriptors = someSortDescriptors;
}

#pragma mark functionality
- (void)tagsHaveChanged
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self
											 selector:@selector(update)
											   object:nil];
	[self performSelector:@selector(update)
			   withObject:nil
			   afterDelay:0.2];

}

- (void)update
{
	// this is not thread-safe!
	[tags sortUsingDescriptors:sortDescriptors];
	
	NSMutableArray *newGroup = [NSMutableArray array];
	
	for (NSInteger i=0;(i<maxSize && i<[tags count]);i++)
	{
		[newGroup addObject:[tags tagAtIndex:i]];
	}
	
	[self setGroupedTags:newGroup];
}

@end
