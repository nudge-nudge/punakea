//
//  FileGroup.m
//  punakea
//
//  Created by Daniel on 18.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "FileGroup.h"


@implementation FileGroup

- (id) init
{
  if (self = [super init])
  {
    NSArray * keys   = [NSArray arrayWithObjects: @"title", nil];
    NSArray * values = [NSArray arrayWithObjects: @"New File Group", nil];
    
    properties = [[NSMutableDictionary alloc]
                      initWithObjects: values forKeys: keys];
        
    files = [[NSMutableArray alloc] init];
  }
  return self;
}

@end
