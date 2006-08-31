//
//  PASimpleTag.m
//  punakea
//
//  Created by Johannes Hoffart on 15.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
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

	[self setQuery:[NSString stringWithFormat:@"kMDItemKeywords = '%@'",aName]];
}

// implementing needed super-class methods
- (float)absoluteRating
{
	//TODO improve on this
	return  (clickCount + useCount);
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
	if ([name isEqual:[otherTag name]] && [query isEqual:[otherTag query]])
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
	[newTag setValue:[self useCount] forKey:@"useCount"];
	[newTag setValue:[self clickCount] forKey:@"clickCount"];
	[newTag setValue:[self lastClicked]  forKey:@"lastClicked"];
	[newTag setValue:[self lastUsed] forKey:@"lastUsed"];
	return newTag;
}

@end