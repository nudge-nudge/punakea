//
//  PATagCache.h
//  punakea
//
//  Created by Johannes Hoffart on 11.05.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PASingleton.h"
#import "PATagCacheEntry.h"

#import "NNTagging/NNTag.h"

@interface PATagCache : NSObject {
	NSMutableDictionary *cache;
}

- (PACacheResult)checkFiletype:(NSString*)filetype forTag:(NNTag*)tag;

- (void)updateCacheForTag:(NNTag*)tag setFiletype:(NSString*)filetype toValue:(BOOL)hasFiletype;

@end
