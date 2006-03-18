//
//  PASimpleTagFactory.m
//  punakea
//
//  Created by Johannes Hoffart on 17.03.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PASimpleTagFactory.h"


@implementation PASimpleTagFactory

- (PATag*)createTagWithName:(NSString*)name query:(NSString*)query;
{
	NSLog(@"error: overriding fixed query in SimpleTag ... NO!");
	return nil;
}

- (PATag*)createTag
{
	return [self createTagWithName:@"noname"];
}

- (PATag*)createTagWithName:(NSString*)name;
{
	PASimpleTag *simpleTag = [[PASimpleTag alloc] initWithName:name];
	return simpleTag;
}

@end
