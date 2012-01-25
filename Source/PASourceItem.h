// Copyright (c) 2006-2012 nudge:nudge (Johannes Hoffart & Daniel Bär). All rights reserved.
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
