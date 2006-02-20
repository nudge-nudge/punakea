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
		
		clickCount = 0;
		useCount = 0;
	}
	return self;
}

- (void)dealloc {
	[name release];
	[query release];
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
}

- (void)incrementUseCount {
	useCount++;
}

- (NSString*)name {
	return name;
}

- (NSString*)query {
	return query;
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