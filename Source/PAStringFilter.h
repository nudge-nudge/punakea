//
//  PAStringFilter.h
//  punakea
//
//  Created by Johannes Hoffart on 11.01.10.
//  Copyright 2010 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NNObjectFilter.h"


@interface PAStringFilter : NNObjectFilter {
	NSString *filter;
}

- (id)initWithFilterPrefix:(NSString*)prefix;
- (NSString*)filterPrefix;

@end
