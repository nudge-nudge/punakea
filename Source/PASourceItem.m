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
		[self setEditable:YES];
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
	[containedObject release];
	[children release];
	
	[displayName release];
	[value release];
	[image release];
	
	[super dealloc];
}


#pragma mark Equality
- (BOOL)isEqual:(id)other 
{
	return [self isEqualTo:other];
}

- (BOOL)isEqualTo:(id)other
{
	if (!other || ![other isMemberOfClass:[self class]]) 
        return NO;
    if (other == self)
        return YES;
	
    return [displayName isEqualTo:[other displayName]];
}

- (unsigned)hash 
{
	return [displayName hash];
}


#pragma mark Copying
- (id)copyWithZone:(NSZone *)zone
{
	PASourceItem *newItem = [[PASourceItem alloc] init];
	
	// abstract class instance vars
	[newItem setValue:[self value]];
	[newItem setDisplayName:[self displayName]];
	[newItem setSelectable:[self isSelectable]];
	[newItem setHeading:[self isHeading]];
	[newItem setEditable:[self isEditable]];
	
	[newItem setContainedObject:[self containedObject]];
	[newItem setParent:[self parent]];
	
	newItem->children = [children copy];
	
	return newItem;
}


#pragma mark Actions
- (void)addChild:(id)anItem
{	
	[anItem validateDisplayName];
	
	[anItem setParent:self];
	[children addObject:anItem];
}

- (void)insertChild:(id)anItem atIndex:(unsigned)idx;
{
	[anItem setParent:self];
	[children insertObject:anItem atIndex:idx];
}

- (void)removeChild:(id)anItem
{
	[children removeObject:anItem];
}

- (void)removeChildWithValue:(NSString *)theValue
{
	for(unsigned i = 0; i < [children count]; i++)
	{
		if([[[children objectAtIndex:i] value] isEqualTo:theValue])
		{
			[children removeObjectAtIndex:i];
			break;
		}
	}
}

- (void)removeChildAtIndex:(int)idx
{
	[children removeObjectAtIndex:idx];
}

- (BOOL)isDescendantOf:(PASourceItem *)anItem
{
	PASourceItem *thisParent = [self parent];
	
	while(thisParent)
	{
		if([thisParent isEqualTo:anItem])
			return YES;
		
		thisParent = [thisParent parent];
	}
	
	return NO;
}

- (BOOL)isDescendantOfValue:(NSString *)anItemValue
{
	PASourceItem *thisParent = [self parent];
	
	while(thisParent)
	{
		if([[thisParent value] isEqualTo:anItemValue])
			return YES;
		
		thisParent = [thisParent parent];
	}
	
	return NO;
}

- (BOOL)isLeaf
{
	if(![self containedObject])
		return NO;
		
	return YES;
}

- (BOOL)hasChildContainingObject:(id)anObject
{
	NSEnumerator *enumerator = [[self children] objectEnumerator];
	PASourceItem *child;
	
	while(child = [enumerator nextObject])
	{
		if([[child containedObject] isEqualTo:anObject])
			return YES;
	}
	
	return NO;
}

- (void)validateDisplayName
{
	// Check on duplicates for display name
	
	NSString *newNameBase = [self displayName];
	NSString *newName = newNameBase;	
	
	BOOL hasDuplicate = YES;
	int numberOfLoops = 0;
	
	while(hasDuplicate)
	{
		hasDuplicate = NO;
		numberOfLoops++;
		
		NSEnumerator *e = [[[self parent] children] objectEnumerator];
		PASourceItem *item;
		while(item = [e nextObject])
		{
			if(item != self &&
			   [[item displayName] isEqualTo:newName])
			{
				hasDuplicate = YES;
				break;
			}
		}
		
		if(hasDuplicate)
			newName = [NSString stringWithFormat:@"%@ (%d)", newNameBase, numberOfLoops];
	}
	
	[self setDisplayName:newName];
	
	if([[self containedObject] isMemberOfClass:[NNTagSet class]])
		[(NNTagSet *)[self containedObject] setName:newName];
}

- (NSString *)defaultDisplayName
{	
	NSString *defaultName = nil;		
	
	if([[self containedObject] isKindOfClass:[NNTag class]])
	{
		defaultName = [(NNTag *)[self containedObject] name];
	}
	else if([[self containedObject] isKindOfClass:[NNTagSet class]])
	{
		defaultName = @"";
		
		NNTagSet *tagSet = [self containedObject];
		
		NSEnumerator *enumerator = [[tagSet tags] objectEnumerator];
		NNTag *tag;
		while(tag = [enumerator nextObject])
		{
			if([defaultName isNotEqualTo:@""]) 
				defaultName = [defaultName stringByAppendingString:@", "];
			
			defaultName = [defaultName stringByAppendingString:[tag name]];
		}
	}
	else
	{
		defaultName = [self displayName];
	}
	
	return defaultName;
}


#pragma mark Misc
- (unsigned int)draggingSourceOperationMaskForLocal:(BOOL)isLocal
{
	return NSDragOperationAll;
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

- (NSImage *)image
{
	return image;
}
- (void)setImage:(NSImage *)anImage
{
	[image release];
	image = [anImage retain];
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

- (BOOL)isEditable
{
	if(heading) return NO;
	
	return editable;
}

- (void)setEditable:(BOOL)flag
{
	editable = flag;
}

- (id)containedObject
{
	return containedObject;
}

- (void)setContainedObject:(id)anObject
{
	[containedObject release];
	containedObject = [anObject retain];
}

- (PASourceItem *)parent
{
	return parent;
}

- (void)setParent:(PASourceItem *)parentItem
{
	[parent release];
	parent = [parentItem retain];
}

- (NSArray *)children
{
	return children;
}

@end
