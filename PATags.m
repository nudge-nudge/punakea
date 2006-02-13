//
//  PATags.m
//  punakea
//
//  Created by Johannes Hoffart on 13.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PATags.h"
#import "PATaggerInterface.h"

@implementation PATags

-(id)init {
	self = [super init];
	if (self) {
		relatedTags = [[NSMutableArray alloc] init];
		activeTags = [[NSMutableArray alloc] init];
		//register with notificationcenter - listen for changes in the query results -- activeFiles is the query
        NSNotificationCenter *nf = [NSNotificationCenter defaultCenter];
        [nf addObserver:self selector:@selector(queryNote:) name:nil object:[[PATaggerInterface sharedInstance] query]];
	}
	return self;
}

-(NSArray*)relatedTags {
	return relatedTags;
}

-(NSArray*)activeTags {
	return activeTags;
}

-(void)queryNote:(NSNotification*)note {
	//TODO implement
}

@end