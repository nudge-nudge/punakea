//
//  PASelectedTags.h
//  punakea
//
//  Created by Johannes Hoffart on 18.04.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PATag.h"

@interface PASelectedTags : NSObject {
	NSMutableArray *selectedTags;
}

- (NSMutableArray*)selectedTags;
- (void)setSelectedTags:(NSMutableArray*)otherTags;
- (void)insertObject:(PATag *)tag inSelectedTagsAtIndex:(unsigned int)i;
- (void)removeObjectFromSelectedTagsAtIndex:(unsigned int)i;

- (unsigned int)count;
- (void)addTag:(PATag*)aTag;
- (void)removeAllObjects;
- (NSEnumerator*)objectEnumerator;
- (PATag*)tagAtIndex:(unsigned int)i;

@end