//
//  PATagCacheEntry.h
//  punakea
//
//  Created by Johannes Hoffart on 11.05.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef UInt32 PACacheResult;

enum
{
	PACacheIsValid = 1 << 0,
	PACacheSatisfiesRequest = 1 << 1
};


@interface PATagCacheEntry : NSObject {
	/**
	an array of filetypes corresponding to the values of 
	 the MDSimpleGrouping.plist
	 */
	NSMutableDictionary *assignedFiletypes;
	
	NSLock *lock; /**< needed to make this thread safe */
}

- (void)setAssignedFiletypes:(NSMutableDictionary*)dic;
- (NSMutableDictionary*)assignedFiletypes;

- (void)setHasFiletype:(NSString*)filetype toValue:(BOOL)hasFiletype;

- (PACacheResult)hasFiletype:(NSString*)filetype forDate:(NSDate*)date;

@end
