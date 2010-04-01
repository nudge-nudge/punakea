//
//  URLHandlerCategory.h
//  punakea
//
//  Created by hoffart on 01.04.10.
//  Copyright 2010 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Core.h"


@interface Core (URLHandlerCategory)

- (NSArray*)tagsForPunakeaURL:(NSString*)tagURL;

@end
