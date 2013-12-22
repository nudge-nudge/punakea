// Copyright (c) 2006-2013 nudge:nudge (Johannes Hoffart & Daniel Bär). All rights reserved.
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

#import "NNAssociationRule.h"

@implementation NNAssociationRule

- (id)initWithContent:(NSArray*)theBody head:(NSArray*)theHead
{
	if (self = [super init]) 
	{
		[self setBody:theBody];
		[self setHead:theHead];
	}
	return self;
}

- (void)dealloc
{
	[body release];
	[head release];
	[super dealloc];
}

- (void)setBody:(NSArray*)theBody
{
	[body release];
	body = [theBody retain];
}

- (NSArray*)body 
{
	return body;
}

- (void)setHead:(NSArray*)theHead
{
	[head release];
	head = [theHead retain];
}

- (NSArray*)head
{
	return head;
}

- (void)setConfidence:(CGFloat)theConfidence
{
	confidence = theConfidence;
}

- (CGFloat)confidence
{
	return confidence;
}

+ (NNAssociationRule*)ruleWithContent:(NSArray*)body head:(NSArray*)head
{
	return [[[NNAssociationRule alloc] initWithContent:body head:head] autorelease];
}

- (NSString*)description {
	NSString *headDesc = [head componentsJoinedByString:@", "];
	NSString *bodyDesc = [body componentsJoinedByString:@", "];
		 
	return [NSString stringWithFormat:@"%@ => %@, %f", bodyDesc, headDesc, confidence];
}


@end
