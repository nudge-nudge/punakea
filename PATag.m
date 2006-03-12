//
//  PATag.m
//  punakea
//
//  Created by Johannes Hoffart on 15.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PATag.h"

@implementation PATag 

- (id)init 
{
	return [self initWithName:NSLocalizedString(@"default tag name",@"tag")];
}

//designated initializer
- (id)initWithName:(NSString*)aName 
{
	if (self = [super init]) 
	{
		[self setName:aName];
		lastClicked = [[NSCalendarDate alloc] init];
		lastUsed = [[NSCalendarDate alloc] init];
		
		clickCount = 0;
		useCount = 0;
	}
	return self;
}

//NSCoding
- (id)initWithCoder:(NSCoder*)coder 
{
	self = [super init];
	if (self) 
	{
		[self setName:[coder decodeObjectForKey:@"name"]];
		[self setQuery:[coder decodeObjectForKey:@"query"]];
		lastClicked = [[coder decodeObjectForKey:@"lastClicked"] retain];
		lastUsed = [[coder decodeObjectForKey:@"lastUsed"] retain];
		[coder decodeValueOfObjCType:@encode(unsigned long)	at:&clickCount];
		[coder decodeValueOfObjCType:@encode(unsigned long)	at:&useCount];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder*)coder 
{
	[coder encodeObject:name forKey:@"name"];
	[coder encodeObject:query forKey:@"query"];
	[coder encodeObject:lastClicked forKey:@"lastClicked"];
	[coder encodeObject:lastUsed forKey:@"lastUsed"];
	[coder encodeValueOfObjCType:@encode(unsigned long) at:&clickCount];
	[coder encodeValueOfObjCType:@encode(unsigned long) at:&useCount];
}

- (void)dealloc 
{
	[name release];
	[query release];
	[lastUsed release];
	[lastClicked release];
	[currentBestTag release];
	[super dealloc];
}

//accessors
- (void)setName:(NSString*)aName 
{
	[aName retain];
	[name release];
	name = aName;
	
	//does this make sense? - TODO
	[self setQuery:[NSString stringWithFormat:@"kMDItemKeywords = '%@'",name]];
}

- (void)setQuery:(NSString*)aQuery 
{
	[aQuery retain];
	[query release];
	query = aQuery;
}

- (void)incrementClickCount 
{
	clickCount++;
	[lastClicked release];
	lastClicked = [[NSCalendarDate alloc] init];
}

- (void)incrementUseCount 
{
	useCount++;
	[lastUsed release];
	lastUsed = [[NSCalendarDate alloc] init];
}

- (void)setCurrentBestTag:(PATag*)aTag
{
	[aTag retain];
	[currentBestTag release];
	currentBestTag = aTag;
}

- (PATag*)currentBestTag 
{
	return currentBestTag;
}

- (NSString*)name 
{
	return name;
}

- (NSString*)query 
{
	return query;
}

- (NSCalendarDate*)lastClicked 
{
	return lastClicked;
}

- (NSCalendarDate*)lastUsed 
{
	return lastUsed;
}

- (unsigned long)clickCount 
{
	return clickCount;
}

- (unsigned long)useCount 
{
	return useCount;
}

- (NSString*)description 
{
	return [NSString stringWithFormat:@"tag: %@",name];
}

//TODO?
- (float)absoluteRating
{
	return  (clickCount + useCount);
}

//returns between 0 and 1 - this can be made faster if we cache the value ... TODO
- (float)relativeRating
{	
	//TODO make quicker implementation, this is for readability
	float relClickCount = [self clickCount] / [currentBestTag clickCount];
	float relUseCount = [self useCount] / [currentBestTag useCount];
	
	float weightClickCount = 0.5;
	float weightUseCount = 0.5;
	
	float weightedClickCount = weightClickCount * relClickCount;
	float weightedUseCount = weightUseCount * relUseCount;
	
	float result = weightedClickCount + weightedUseCount;
	
	return result;
}

//---- BEGIN isEqual: stuff ----
- (BOOL)isEqual:(id)other 
{
	if (!other || ![other isKindOfClass:[self class]]) 
        return NO;
    if (other == self)
        return YES;
    return [self isEqualToTag:other];
}

- (BOOL)isEqualToTag:(PATag*)otherTag 
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
//---- END isEqual: stuff ----

@end