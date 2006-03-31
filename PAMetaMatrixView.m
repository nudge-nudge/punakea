//
//  PAMetaMatrix.m
//  punakea
//
//  Created by Daniel on 30.03.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAMetaMatrix.h"


@implementation PAMetaMatrix

#pragma mark Accessors
- (id)delegate {
    return delegate;
}
 
- (void)setDelegate:(id)newDelegate {
    delegate = newDelegate;
}

@end
