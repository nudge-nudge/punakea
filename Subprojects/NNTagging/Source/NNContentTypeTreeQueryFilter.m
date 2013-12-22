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

#import "NNContentTypeTreeQueryFilter.h"


@implementation NNContentTypeTreeQueryFilter

#pragma mark init
- (id)initWithType:(NSString*)aContentTypeIdentifier
{
	if (self = [super init])
	{
		contentTypeIdentifier = [aContentTypeIdentifier copy];
		
		// load groupings
		NSString *path = [[NSBundle mainBundle] pathForResource:@"MDSimpleGrouping" ofType:@"plist"];
		NSDictionary *simpleGrouping = [NSDictionary dictionaryWithContentsOfFile:path];
		
		// add filters for every resource type
		NSArray *contentValues = [simpleGrouping allKeysForObject:contentTypeIdentifier];
		
		predicate = [[NSMutableString alloc] init];
		
		NSEnumerator *e = [contentValues objectEnumerator];
		NSString *aContentType;
		
		if (aContentType = [e nextObject])
		{
			[predicate appendFormat:@"%@ == \"%@\"",kMDItemContentTypeTree,aContentType];
		}
			
		while (aContentType = [e nextObject])
		{
			[predicate appendFormat:@" || %@ == \"%@\"",kMDItemContentTypeTree,aContentType];
		}
	
		// add ( ) to the string
		if ([predicate length] > 0)
		{
			[predicate insertString:@"(" atIndex:0];
			[predicate appendString:@")"];
		}
	}
	return self;
}
		
		
+ (NNContentTypeTreeQueryFilter*)contentTypeTreeQueryFilterForType:(NSString*)contentTypeIdentifier
{
	NNContentTypeTreeQueryFilter *filter = [[NNContentTypeTreeQueryFilter alloc] initWithType:contentTypeIdentifier];
	return [filter autorelease];
}

- (void)dealloc
{
	[contentTypeIdentifier release];
	[predicate release];
	[super dealloc];
}

#pragma mark abstract implemented
- (NSString*)filterPredicateString
{
	return predicate;
}

#pragma mark description
- (NSString*)description
{
	return [NSString stringWithFormat:@"ContentTypeTreeFilter: %@ (%@)",contentTypeIdentifier,predicate];
}

@end
