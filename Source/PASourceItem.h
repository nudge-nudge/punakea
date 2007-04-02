//
//  PASourceItem.h
//  punakea
//
//  Created by Daniel on 28.03.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PASourceItem : NSObject {

	NSString				*value;
	NSString				*displayName;
	BOOL					selectable;
	BOOL					heading;
	
	id						containedObject;
	PASourceItem			*parent;
	
	NSMutableArray			*children;
	
}

+ (PASourceItem *)itemWithValue:(NSString *)aValue displayName:(NSString *)aDisplayName;

- (void)addChild:(id)anItem;
- (void)insertChild:(id)anItem atIndex:(unsigned)idx;
- (void)removeChildWithValue:(NSString *)theValue;

- (BOOL)isDescendantOf:(PASourceItem *)anItem;
- (BOOL)isDescendantOfValue:(NSString *)anItemValue;
- (BOOL)isLeaf;
- (BOOL)hasChildContainingObject:(id)anObject;

- (NSString *)value;
- (void)setValue:(NSString *)aString;
- (NSString *)displayName;
- (void)setDisplayName:(NSString *)aString;
- (BOOL)isSelectable;
- (void)setSelectable:(BOOL)flag;
- (BOOL)isHeading;
- (void)setHeading:(BOOL)flag;

- (id)containedObject;
- (void)setContainedObject:(id)anObject;
- (PASourceItem *)parent;
- (void)setParent:(PASourceItem *)parentItem;

- (NSArray *)children;

@end
