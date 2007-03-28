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
		[self setValue:@""];
		[self setDisplayName:@""];
		[self setSelectable:YES];
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
	[super dealloc];
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

@end
