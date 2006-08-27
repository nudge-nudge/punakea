//
//  PATags.h
//  punakea
//
//  Created by Johannes Hoffart on 18.04.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PATag.h"

//TODO wrapping in userInfo neccessary?!
typedef enum _PATagChangeOperation
{
	PATagRemoveOperation = 0,
	PATagAddOperation = 1,
	PATagResetOperation = 2
} PATagChangeOperation;


@interface PATags : NSObject {
	NSMutableArray *tags;
	
	NSNotificationCenter *nc;
}

- (PATag*)tagForName:(NSString*)tagName;

- (NSMutableArray*)tags;
- (void)setTags:(NSMutableArray*)otherTags;

- (void)addTag:(PATag*)aTag;
- (void)removeTag:(PATag*)aTag;
- (NSEnumerator*)objectEnumerator;
- (int)count;

@end