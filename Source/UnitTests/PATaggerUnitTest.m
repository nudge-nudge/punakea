//
//  PATaggerUnitTest.m
//  punakea
//
//  Created by Johannes Hoffart on 01.11.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "PATaggerUnitTest.h"


@implementation PATaggerUnitTest

- (void)setUp
{
	filenames = [[NSArray alloc] initWithObjects:@"/tmp/nudgenudge_unittestfile_0",
		@"/tmp/nudgenudge_unittestfile_1",
		@"/tmp/nudgenudge_unittestfile_2",
		nil];
	
	// create tags
	testTags = [NSMutableArray array];
	NNSimpleTag *test_0 = [[NNSimpleTag alloc] initWithName:@"test_0"];
	NNSimpleTag *test_1 = [[NNSimpleTag alloc] initWithName:@"test_1"];
	NNSimpleTag *test_2 = [[NNSimpleTag alloc] initWithName:@"test_2"];
	NNSimpleTag *test_3 = [[NNSimpleTag alloc] initWithName:@"test_3"];
	NNSimpleTag *test_4 = [[NNSimpleTag alloc] initWithName:@"test_4"];
	NNSimpleTag *test_5 = [[NNSimpleTag alloc] initWithName:@"test_5"];
	NNSimpleTag *test_6 = [[NNSimpleTag alloc] initWithName:@"test_6"];
	NNSimpleTag *test_7 = [[NNSimpleTag alloc] initWithName:@"test_7"];
	NNSimpleTag *test_8 = [[NNSimpleTag alloc] initWithName:@"test_8"];
	NNSimpleTag *test_9 = [[NNSimpleTag alloc] initWithName:@"test_9"];
	
	[testTags addObject:test_0];
	[testTags addObject:test_1];
	[testTags addObject:test_2];
	[testTags addObject:test_3];
	[testTags addObject:test_4];
	[testTags addObject:test_5];
	[testTags addObject:test_6];
	[testTags addObject:test_7];
	[testTags addObject:test_8];
	[testTags addObject:test_9];
	
	tags = [NNTags sharedTags;
	[tags addTag:test_0];
	[tags addTag:test_1];
	[tags addTag:test_2];
	[tags addTag:test_3];
	[tags addTag:test_4];
	[tags addTag:test_5];
	[tags addTag:test_6];
	[tags addTag:test_7];
	[tags addTag:test_8];
	[tags addTag:test_9];
	
	[self createTestFiles:filenames];
}

- (void)tearDown
{
	[self removeTestFiles:filenames];
	[tags release];
	[testTags release];
	[simpleTagFactory release];
	[filenames release];
}

- (void)testTagging
{
			
	NNFile *file_0 = [NNFile fileWithPath:[filenames objectAtIndex:0]];
	NNFile *file_1 = [NNFile fileWithPath:[filenames objectAtIndex:0]];
	NNFile *file_2 = [NNFile fileWithPath:[filenames objectAtIndex:0]];
	
	[tagger addTags:testTags toFiles:[NSArray arrayWithObject:file_0]];
	NSArray *tagsOnFiles = [tagger tagsOnFile:file_0];
	
	[self assertArrayContentOf:tagsOnFiles isEqualTo:testTags];
		
	[tagger removeAllTagsFromFile:file_0];
	tagsOnFiles = [tagger tagsOnFile:file_0];
	
	[self assertArrayContentOf:tagsOnFiles isEqualTo:[NSArray array]];
	
	[tagger addTags:[NSArray arrayWithObjects:[testTags objectAtIndex:0],
		[testTags objectAtIndex:2],
		nil]
									  toFiles:[NSArray arrayWithObject:file_1]];
	
	[tagger addTags:[NSArray arrayWithObjects:[testTags objectAtIndex:0],
		[testTags objectAtIndex:2],
		nil]
			toFiles:[NSArray arrayWithObject:file_2]];
	
	[tagger addTags:[NSArray arrayWithObjects:[testTags objectAtIndex:5],
		[testTags objectAtIndex:8],
		nil]
			toFiles:[NSArray arrayWithObject:file_1]];
		
	[self assertArrayContentOf:[tagger tagsOnFile:file_1]
					 isEqualTo:[NSArray arrayWithObjects:[testTags objectAtIndex:0],[testTags objectAtIndex:2],[testTags objectAtIndex:5],[testTags objectAtIndex:8],nil]];

}

#pragma mark private
- (void)createTestFiles:(NSArray*)files
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *nudgenudge = @"nudgenudge";
	NSData *defaultData = [NSData dataWithBytes:[nudgenudge cString] length:[nudgenudge cStringLength]];
	
	NSEnumerator *e = [files objectEnumerator];
	NSString *filename;
	
	while (filename = [e nextObject])
	{
		[fileManager createFileAtPath:filename 
							 contents:defaultData
						   attributes:nil];
	}
}

- (void)removeTestFiles:(NSArray*)files
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSEnumerator *e = [files objectEnumerator];
	NSString *filename;
	
	while (filename = [e nextObject])
	{
		//[fileManager removeFileAtPath:filename handler:nil];
	}
}


- (void)assertArrayContentOf:(NSArray*)a isEqualTo:(NSArray*)b
{
	STAssertEquals([a count],[b count],@"size");
	
	NSEnumerator *e = [a objectEnumerator];
	NNTag *tag;
	
	while (tag = [e nextObject])
	{
		STAssertTrue([b containsObject:tag],@"tag");
	}
}

@end
