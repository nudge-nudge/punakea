//
//  NSString+CharacterSetChecks.m
//  punakea
//
//  Created by Johannes Hoffart on 02.10.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "NSString+CharacterSetChecks.h"


@implementation NSString (CharacterSetChecks)

- (BOOL)isWhiteSpace
{
	// empty string is whitespace
	if ([self isEqualToString:@""])
	{
		return YES;
	}
	
	NSCharacterSet *wscs = [NSCharacterSet whitespaceCharacterSet];
	BOOL isWhitespace = YES;
	
	for (int i=0;i<[self length];i++)
	{
		if (![wscs characterIsMember:[self characterAtIndex:i]])
			isWhitespace = NO;
	}
	
	return isWhitespace;
}

@end
