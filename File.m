//
//  File.h
//  punakea
//
//  Created by Daniel on 18.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "File.h"


@implementation File

- (id) init
{
  if (self = [super init])
  {
    NSArray * keys   = [NSArray arrayWithObjects: @"title", nil];
    NSArray * values = [NSArray arrayWithObjects: @"New File", nil];
    
    properties = [[NSMutableDictionary alloc]
                      initWithObjects: values forKeys: keys];
  }
  return self;
}

- (NSMutableDictionary *) properties {
	return properties;
}

@end
