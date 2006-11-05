//
//  PATaggerUnitTest.h
//  punakea
//
//  Created by Johannes Hoffart on 01.11.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "PASimpleTagFactory.h"	
#import "PAFile.h"
#import "PATagger.h"
#import "PATags.h"

@interface PATaggerUnitTest : SenTestCase {
	NSArray *filenames;
	PATagger *tagger;
	PATags *tags;
	PASimpleTagFactory *simpleTagFactory;
	NSMutableArray *testTags;
}

- (void)assertArrayContentOf:(NSArray*)a isEqualTo:(NSArray*)b;

@end
