//
//  NNContentTypeFilter.m
//  NNTagging
//
//  Created by Johannes Hoffart on 19.04.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "NNContentTypeFilter.h"


@implementation NNContentTypeFilter

#pragma mark init
- (id)initWithContentType:(NSString*)type
{
	if (self = [super init])
	{
		weight = 10;
		contentType = [type copy];
	}
	return self;
}

- (void)dealloc
{
	[contentType release];
	[super dealloc];
}

#pragma mark accessors
- (NSString*)contentType
{
	return contentType;
}

#pragma mark function
- (void)filterObject:(id)object
{
	// TODO
}

@end
