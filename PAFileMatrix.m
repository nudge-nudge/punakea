//
//  PAFileMatrix.m
//  punakea
//
//  Created by Daniel on 08.03.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAFileMatrix.h"


@implementation PAFileMatrix

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

/* - (void)drawRect:(NSRect)rect {
    // Drawing code here.
} */

- (void)initWithMetadataQuery:(NSMetadataQuery*)aQuery {
	query = aQuery;
	NSNotificationCenter *nf = [NSNotificationCenter defaultCenter];
    [nf addObserver:self selector:@selector(queryNote:) name:nil object:query];
}


- (void)queryNote:(NSNotification *)note {
        NSLog(@"queryNote received");
}
@end
