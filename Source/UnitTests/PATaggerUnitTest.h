//
//  PATaggerUnitTest.h
//  punakea
//
//  Created by Johannes Hoffart on 01.11.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "NNTagging/NNFile.h"
#import "NNTagging/NNTags.h"
#import "NNTagging/NNSimpleTag.h"

@interface PATaggerUnitTest : SenTestCase {
	NSArray *filenames;
	PATagger *tagger;
	NNTags *tags;
	NNSimpleTagFactory *simpleTagFactory;
	NSMutableArray *testTags;
}

- (void)assertArrayContentOf:(NSArray*)a isEqualTo:(NSArray*)b;

@end
