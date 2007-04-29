//
//  NNStringPrefixFilter.m
//  NNTagging
//
//  Created by Johannes Hoffart on 18.04.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "NNStringPrefixFilter.h"


@implementation NNStringPrefixFilter

#pragma mark init
- (id)initWithFilterPrefix:(NSString*)prefix
{
	if (self = [super init])
	{
		weight = 1;
		filterPrefix = [prefix copy];
	}
	return self;
}

- (void)dealloc
{
	[filterPrefix release];
	[super dealloc];
}

#pragma mark accessors
- (NSString*)filterPrefix
{
	return filterPrefix;
}

#pragma mark function
- (void)filterObject:(id)object
{
	NSString *tagName = [object name];
	
	if ([tagName hasPrefix:filterPrefix])
	{
		NSLog(@"%@ : %@",self,object);
		[self objectFiltered:object];
	}
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"StringPrefixFilter: %@",filterPrefix];
}

@end
