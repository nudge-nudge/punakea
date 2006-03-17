//
//  PATagFactory.m
//  punakea
//
//  Created by Johannes Hoffart on 17.03.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PATagFactory.h"


@implementation PATagFactory

- (id)init
{
	self = [super init];
	return self;
}

- (id <PATag>)createTag
{
	return nil;
}

- (id <PATag>)createTagWithName:(NSString*)name;
{
	return nil;
}

- (id <PATag>)createTagWithName:(NSString*)name query:(NSString*)query;
{
	return nil;
}

@end
