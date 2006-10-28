//
//  PACollectionNotEmpty.m
//  punakea
//
//  Created by Johannes Hoffart on 28.10.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "PACollectionNotEmpty.h"


@implementation PACollectionNotEmpty

+ (Class)transformedValueClass
{
	return [NSNumber class];
}

- (BOOL)allowsReverseTransformation
{
	return NO;
}

- (id)transformedValue:(id)value
{
	if ([value isKindOfClass:[NSArray class]]
		|| [value isKindOfClass:[NSSet class]]
		|| [value isKindOfClass:[NSDictionary class]])
	{
		return [NSNumber numberWithBool:([value count] > 0)];
	}
	else
	{
		return NO;
	}
}

@end
