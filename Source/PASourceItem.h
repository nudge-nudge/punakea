//
//  PASourceItem.h
//  punakea
//
//  Created by Daniel on 28.03.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NNTagging/NNTag.h"
#import "NNTagging/NNTagSet.h"


@interface PASourceItem : NSObject {

	NSString				*value;
	NSString				*displayName;
	NSImage					*image;
	
	BOOL					selectable;
	BOOL					heading;
	BOOL					editable;
	
	id						containedObject;
	PASourceItem			*parent;
	
	NSMutableArray			*children;
	
}

+ (PASourceItem *)itemWithValue:(NSString *)aValue displayName:(NSString *)aDisplayName;

- (void)addChild:(id)anItem;
- (void)insertChild:(id)anItem atIndex:(NSUInteger)idx;
- (void)removeChild:(id)anItem;
- (void)removeChildWithValue:(NSString *)theValue;
- (void)removeChildAtIndex:(NSInteger)idx;

- (BOOL)isDescendantOf:(PASourceItem *)anItem;
- (BOOL)isDescendantOfValue:(NSString *)anItemValue;
- (BOOL)isLeaf;
- (BOOL)hasChildContainingObject:(id)anObject;

- (void)validateDisplayName;			/**< Checks all children of this item's parent for the display name. If there's a duplicate, append an index to the current display name to solve conflict. */
- (NSString *)defaultDisplayName;		/**< Returns the display name that indicates the default. For a tag as contained object it's the tag's name. For a tag set it's a comma separated list of tag names. Otherwise returns the current display name.*/

- (NSString *)value;
- (void)setValue:(NSString *)aString;
- (NSString *)displayName;
- (void)setDisplayName:(NSString *)aString;
- (NSImage *)image;
- (void)setImage:(NSImage *)anImage;
- (BOOL)isSelectable;
- (void)setSelectable:(BOOL)flag;
- (BOOL)isHeading;
- (void)setHeading:(BOOL)flag;
- (BOOL)isEditable;
- (void)setEditable:(BOOL)flag;

- (id)containedObject;
- (void)setContainedObject:(id)anObject;
- (PASourceItem *)parent;
- (void)setParent:(PASourceItem *)parentItem;

- (NSArray *)children;

@end
