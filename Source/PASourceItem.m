//
//  PASourceItem.m
//  punakea
//
//  Created by Daniel on 28.03.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PASourceItem.h"


@implementation PASourceItem

#pragma mark Init + Dealloc
- (id)init
{
	if (self = [super init])
	{
		children = [[NSMutableArray alloc] init];
		
		[self setValue:@""];
		[self setDisplayName:@""];
		[self setSelectable:YES];
		[self setHeading:NO];
	}
	return self;
}

+ (PASourceItem *)itemWithValue:(NSString *)aValue displayName:(NSString *)aDisplayName
{
	PASourceItem *item = [[PASourceItem alloc] init];
	[item setValue:aValue];
	[item setDisplayName:aDisplayName];
	
	return [item autorelease];
}

- (void)dealloc
{
	[children release];
	[super dealloc];
}


#pragma mark Equality
- (BOOL)isEqual:(id)other 
{
	return [self isEqualTo:other];
}

- (BOOL)isEqualTo:(id)other
{
	if (!other || ![other isKindOfClass:[self class]]) 
        return NO;
    if (other == self)
        return YES;
	
    return [value isEqualTo:[other value]];
}

- (unsigned)hash 
{
	return [value hash];
}


#pragma mark Copying
- (id)copyWithZone:(NSZone *)zone
{
	PASourceItem *newItem = [[PASourceItem alloc] init];
	
	// abstract class instance vars
	[newItem setValue:[self value]];
	[newItem setDisplayName:[self displayName]];
	[newItem setSelectable:[self isSelectable]];
	
	newItem->children = [children copy];
	
	return [newItem autorelease];
}


#pragma mark Actions
- (void)addChild:(id)anItem
{
	[children addObject:anItem];
}

- (void)insertChild:(id)anItem atIndex:(unsigned)idx;
{
	[children insertObject:anItem atIndex:idx];
}


#pragma mark Accessors
- (NSString *)value
{
	return value;
}

- (void)setValue:(NSString *)aString
{
	[value release];
	value = [aString retain];	
}

- (NSString *)displayName
{
	return displayName;
}

- (void)setDisplayName:(NSString *)aString
{
	[displayName release];
	displayName = [aString retain];
}

- (BOOL)isSelectable
{
	return selectable;
}

- (void)setSelectable:(BOOL)flag
{
	selectable = flag;
}

- (BOOL)isHeading
{
	return heading;
}

- (void)setHeading:(BOOL)flag
{
	heading = flag;
}

- (NSArray *)children
{
	return children;
}

@end
