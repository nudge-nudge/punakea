//
//  PABoolToColorTransformer.m
//  punakea
//
//  Created by Daniel on 29.01.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PABoolToColorTransformer.h"


@implementation PABoolToColorTransformer

+ (Class)transformedValueClass
{
    return [NSColor class];
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)aBool
{	
    BOOL state = [aBool boolValue];
    
	if (!state)
		return [NSColor disabledControlTextColor];
	
	return [NSColor textColor];
}

@end
