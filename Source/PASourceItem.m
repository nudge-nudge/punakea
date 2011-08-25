// Copyright (c) 2006-2011 nudge:nudge (Johannes Hoffart & Daniel Bär). All rights reserved.
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

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

- (NSUInteger)hash 
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

- (void)insertChild:(id)anItem atIndex:(NSUInteger)idx;
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
	for(NSUInteger i = 0; i < [children count]; i++)
	{
		if([[[children objectAtIndex:i] value] isEqualTo:theValue])
		{
			[children removeObjectAtIndex:i];
			break;
		}
	}
}

- (void)removeChildAtIndex:(NSInteger)idx
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
	NSInteger numberOfLoops = 0;
	
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
			newName = [NSString stringWithFormat:@"%@ (%ld)", newNameBase, numberOfLoops];
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
- (NSUInteger)draggingSourceOperationMaskForLocal:(BOOL)isLocal
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
