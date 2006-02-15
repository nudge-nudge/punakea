//
//  PATag.m
//  punakea
//
//  Created by Johannes Hoffart on 15.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PATag.h"

@implementation PATag 

-(id)initWithName:(NSString*)aName {
	return [self initWithName:aName query:nil];
}

//designated initializer
-(id)initWithName:(NSString*)aName query:(NSString*)aQuery {
	self = [super init];
	if (self) {
		if (!aQuery) aQuery = NSLocalizedString(@"default tag name","new Tag");

		name = [aName copy];
		query = [aQuery copy];
	}
	return self;
}

-(void)dealloc {
	[name release];
	[query release];
	[super dealloc];
}

-(void)setName:(NSString*)aName {
	[aName retain];
	[name release];
	name = aName;
}

-(void)setQuery:(NSString*)aQuery {
	[aQuery retain];
	[query release];
	query = aQuery;
}

-(NSString*)name {
	return name;
}

-(NSString*)query {
	return query;
}

@end