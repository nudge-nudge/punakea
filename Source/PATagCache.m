// Copyright (c) 2006-2011 nudge:nudge (Johannes Hoffart & Daniel Bär). All rights reserved.
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
		cacheLock = [[NSLock alloc] init];
	}
	return self;
}

#pragma mark accessors
- (void)setCache:(NSMutableDictionary*)aCache
{
	[aCache retain];
	[cache release];
	cache = aCache;
}

- (NSMutableDictionary*)cache
{
	return cache;
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
	//NSLog(@"update: %@ for %@ to %i",tag,filetype,hasFiletype);
	
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
	
		[cacheLock lock];
		[cache setObject:entry forKey:[tag name]];
		[cacheLock unlock];
		
		[entry release];
	}
}

@end
