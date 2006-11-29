//
//  PAFilterButton.h
//  punakea
//
//  Created by Daniel on 06.09.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PAButton.h"


@interface PAFilterButton : PAButton {

	NSMutableDictionary			*filter;

}

- (NSMutableDictionary *)filter;
- (void)setFilter:(NSDictionary *)dictionary;

@end
