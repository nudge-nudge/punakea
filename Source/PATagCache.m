//
//  PATagCache.m
//  punakea
//
//  Created by Johannes Hoffart on 11.05.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PATagCache.h"

@implementation PATagCache

#pragma mark singleton stuff
static PATagCache *sharedInstance = nil;

+ (PATagCache*)sharedInstance
{
    @synchronized(self) {
        if (sharedInstance == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}

#pragma mark init
- (id)init
{
	if (self = [super init])
	{
		cache = [[NSMutableDictionary alloc] init];
	}
	return self;
}

#pragma mark function
- (PACacheResult)checkFiletype:(NSString*)filetype forTag:(NNTag*)tag
{
	PATagCacheEntry *entry = [cache objectForKey:[tag name]];
	
	PACacheResult result = 0;
	
	if (entry)
	{
		result = [entry hasFiletype:filetype forDate:[tag lastUsed]];
	}
	
	return result;
}


- (void)updateCacheForTag:(NNTag*)tag setFiletype:(NSString*)filetype toValue:(BOOL)hasFiletype;
{
	PATagCacheEntry *entry = [cache objectForKey:[tag name]];
	
	if (entry)
	{
		[entry setHasFiletype:filetype toValue:hasFiletype];
	}
	else
	{
		// create new entry
		entry = [[PATagCacheEntry alloc] init];
		[entry setHasFiletype:filetype toValue:hasFiletype];
		[cache setObject:entry forKey:[tag name]];
		[entry release];
	}
}

@end
