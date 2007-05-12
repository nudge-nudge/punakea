//
//  PASingleton.m
//  punakea
//
//  Created by Johannes Hoffart on 11.05.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PASingleton.h"


@implementation PASingleton

/*
 copy this to subclasses

static PASingleton *sharedInstance = nil;

+ (PASingleton*)sharedInstance
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

*/

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (unsigned)retainCount
{
    return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

@end
