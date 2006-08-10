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
	NSMutableDictionary *tags;
	
	NSNotificationCenter *nc;
}

- (NSArray*)tagArray;
- (PATag*)tagForName:(NSString*)tagName;

- (NSMutableDictionary*)tags;
- (void)setTags:(NSMutableDictionary*)otherTags;

- (void)addTag:(PATag*)aTag;
- (NSEnumerator*)objectEnumerator;

@end