//
//  NNContentTypeFilter.h
//  NNTagging
//
//  Created by Johannes Hoffart on 19.04.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NNObjectFilter.h"

@interface NNContentTypeFilter : NNObjectFilter {
	NSString *contentType;
}

- (id)initWithContentType:(NSString*)type;
- (NSString*)contentType;

@end
