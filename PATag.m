//
//  PATag.m
//  punakea
//
//  Created by Johannes Hoffart on 15.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PATag.h"

@implementation PATag 

- (id)initWithName:(NSString*)aName {
	return [self initWithName:aName query:nil];
}

//designated initializer
- (id)initWithName:(NSString*)aName query:(NSString*)aQuery {
	self = [super init];
	if (self) {
		if (!aQuery) aQuery = NSLocalizedString(@"default tag name","new Tag");

		name = [aName copy];
		query = [aQuery copy];
		lastClicked = [[NSCalendarDate alloc] init];
		lastUsed = [[NSCalendarDate alloc] init];
		
		clickCount = 0;
		useCount = 0;
	}
	return self;
}

//NSCoding
- (id)initWithCoder:(NSCoder*)coder {
	self = [super init];
	if (self) {
		[self setName:[coder decodeObjectForKey:@"name"]];
		[self setQuery:[coder decodeObjectForKey:@"query"]];
		lastClicked = [[coder decodeObjectForKey:@"lastClicked"] retain];
		lastUsed = [[coder decodeObjectForKey:@"lastUsed"] retain];
		[coder decodeValueOfObjCType:@encode(unsigned long)	at:&clickCount];
		[coder decodeValueOfObjCType:@encode(unsigned long)	at:&useCount];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder*)coder {
	[coder encodeObject:name forKey:@"name"];
	[coder encodeObject:query forKey:@"query"];
	[coder encodeObject:lastClicked forKey:@"lastClicked"];
	[coder encodeObject:lastUsed forKey:@"lastUsed"];
	[coder encodeValueOfObjCType:@encode(unsigned long) at:&clickCount];
	[coder encodeValueOfObjCType:@encode(unsigned long) at:&useCount];
}

- (void)dealloc {
	[name release];
	[query release];
	[lastUsed release];
	[lastClicked release];
	[super dealloc];
}

//accessors
- (void)setName:(NSString*)aName {
	[aName retain];
	[name release];
	name = aName;
}

- (void)setQuery:(NSString*)aQuery {
	[aQuery retain];
	[query release];
	query = aQuery;
}

- (void)incrementClickCount {
	clickCount++;
	[lastClicked release];
	lastClicked = [[NSCalendarDate alloc] init];
}

- (void)incrementUseCount {
	useCount++;
	[lastUsed release];
	lastUsed = [[NSCalendarDate alloc] init];
}

- (NSString*)name {
	return name;
}

- (NSString*)query {
	return query;
}

- (NSCalendarDate*)lastClicked {
	return lastClicked;
}

- (NSCalendarDate*)lastUsed {
	return lastUsed;
}

- (unsigned long)clickCount {
	return clickCount;
}

- (unsigned long)useCount {
	return useCount;
}

//---- BEGIN isEqual: stuff ----
- (BOOL)isEqual:(id)other {
	if (!other || ![other isKindOfClass:[self class]]) 
        return NO;
    if (other == self)
        return YES;
    return [self isEqualToTag:other];
}

- (BOOL)isEqualToTag:(PATag*)otherTag {
	if ([name isEqual:[otherTag name]] && [query isEqual:[otherTag query]]) {
		return YES;
	} else {
		return NO;
	}
}

- (unsigned)hash {
	return [name hash] ^ [query hash];
}
//---- END isEqual: stuff ----

@end