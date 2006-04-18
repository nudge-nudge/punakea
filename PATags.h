//
//  PATags.h
//  punakea
//
//  Created by Johannes Hoffart on 18.04.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PATag.h"

@interface PATags : NSObject {
	NSMutableArray *tags;
}

- (NSMutableArray*)tags;
- (void)setTags:(NSMutableArray*)otherTags;
- (void)insertObject:(PATag *)tag inTagsAtIndex:(unsigned int)i;
- (void)removeObjectFromTagsAtIndex:(unsigned int)i;

- (void)addTag:(PATag*)aTag;

@end