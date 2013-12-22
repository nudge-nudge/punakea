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

#import "NNAssociationRules.h"

@interface NNAssociationRules (PrivateAPI)

- (void)addRule:(NNAssociationRule*)rule;

@end

@implementation NNAssociationRules

- (id)initWithRules:(NSArray*)someRules
{
	if (self =[super init])
	{
		rules = [[NSMutableDictionary alloc] init];

		for (NNAssociationRule *rule in someRules)
		{
			[self addRule:rule];
		}
	}
	
	return self;
}

- (void)dealloc
{
	[rules release];
	[super dealloc];
}

#pragma mark functionality
- (void)addRule:(NNAssociationRule*)rule
{
	// sort the body - requests will also be sorted
	// the body will function as lookup key
	NSArray *sortedBody = [[rule body] sortedArrayUsingSelector:@selector(localizedCompare:)];
	[rules setObject:rule forKey:sortedBody];
}

- (NSArray*)associatedTagsForTags:(NSArray*)tags
{
	// we need to sort because dictionary keys are sorted
	NSArray *sortedTags = [tags sortedArrayUsingSelector:@selector(localizedCompare:)];
	
	// find the maximum matching rule head
	NSArray *associatedTags = nil;
	
	for (int i=[sortedTags count];(associatedTags == nil) && (i>0);i--)
	{
		NSRange currentRange = NSMakeRange(0, i);
		NSArray *currentTags = [sortedTags subarrayWithRange:currentRange];
		
		// the head of the rule are the associateed tags
		NNAssociationRule *rule = [rules objectForKey:currentTags];
		associatedTags = [rule head];
	}
	
	// default is no associated tags
	if (associatedTags == nil)
	{
		associatedTags = [NSArray array];
	}
	
	return associatedTags;	
}

- (NSString*)description
{
	NSMutableString *desc = [NSMutableString stringWithString:@"Association Rules:\n"];
	
	for (NSString *key in [rules allKeys])
	{
		[desc appendFormat:@"%@\n",[[rules objectForKey:key] description]];
	}
	
	return desc;
}

@end
