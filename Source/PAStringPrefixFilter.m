//
//  PAStringPrefixFilter.m
//  NNTagging
//
//  Created by Johannes Hoffart on 18.04.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PAStringPrefixFilter.h"


@implementation PAStringPrefixFilter


#pragma mark function
- (void)filterObject:(id)object
{
	NSString *tagName = [object name];
	
	if ([[tagName lowercaseString] hasPrefix:filter])
	{
		[self objectFiltered:object];
	}
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"StringPrefixFilter: %@",filter];
}

@end
