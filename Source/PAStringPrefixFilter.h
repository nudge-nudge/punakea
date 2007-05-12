//
//  PAStringPrefixFilter.h
//  NNTagging
//
//  Created by Johannes Hoffart on 18.04.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NNObjectFilter.h"

@interface PAStringPrefixFilter : NNObjectFilter {
	NSString *filterPrefix;
}

- (id)initWithFilterPrefix:(NSString*)prefix;
- (NSString*)filterPrefix;

@end
