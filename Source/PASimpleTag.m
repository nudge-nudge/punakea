//
//  PASimpleTag.m
//  punakea
//
//  Created by Johannes Hoffart on 15.02.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "PASimpleTag.h"
@interface PASimpleTag (PrivateAPI)

- (BOOL)isEqualToTag:(PASimpleTag*)otherTag;

@end

@implementation PASimpleTag

#pragma mark functionality
// overwriting super-class methods
- (void)setName:(NSString*)aName 
{
	[super setName:aName];

	[self setQuery:[NSString stringWithFormat:@"kMDItemFinderComment LIKE '*tag:%@*'",aName]];
}

- (NSString*)queryInSpotlightSyntax
{
	return [NSString stringWithFormat:@"kMDItemKeywords == \"%@\"cd",[self name]];
}

// implementing needed super-class methods
- (float)absoluteRating
{
	return log10(clickCount + useCount);
}

- (float)relativeRatingToTag:(PATag*)otherTag
{	
	return [self absoluteRating] / [otherTag absoluteRating];
}

#pragma mark euality testing
- (BOOL)isEqual:(id)other 
{
	if (!other || ![other isKindOfClass:[self class]]) 
        return NO;
    if (other == self)
        return YES;
	
    return [self isEqualToTag:other];
}

- (BOOL)isEqualToTag:(PASimpleTag*)otherTag 
{
	if ([name caseInsensitiveCompare:[otherTag name]] == NSOrderedSame 
		&& [query isEqual:[otherTag query]])
		return YES;
	else
		return NO;
}

- (unsigned)hash 
{
	return [name hash] ^ [query hash];
}

#pragma mark copying
- (id)copyWithZone:(NSZone *)zone
{
	PASimpleTag *newTag = [[[PASimpleTag alloc] init] autorelease];
	[newTag setName:[self name]];
	[newTag setUseCount:[self useCount]];
	[newTag setValue:[self lastUsed] forKey:@"lastUsed"];
	[newTag setClickCount:[self clickCount]];
	[newTag setValue:[self lastClicked]  forKey:@"lastClicked"];
	return newTag;
}

@end