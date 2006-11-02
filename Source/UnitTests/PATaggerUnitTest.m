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
	
	simpleTagFactory = [[PASimpleTagFactory alloc] init];
	
	// create tags
	testTags = [NSMutableArray array];
	PASimpleTag *test_0 = [simpleTagFactory createTagWithName:@"test_0"];
	PASimpleTag *test_1 = [simpleTagFactory createTagWithName:@"test_1"];
	PASimpleTag *test_2 = [simpleTagFactory createTagWithName:@"test_2"];
	PASimpleTag *test_3 = [simpleTagFactory createTagWithName:@"test_3"];
	PASimpleTag *test_4 = [simpleTagFactory createTagWithName:@"test_4"];
	PASimpleTag *test_5 = [simpleTagFactory createTagWithName:@"test_5"];
	PASimpleTag *test_6 = [simpleTagFactory createTagWithName:@"test_6"];
	PASimpleTag *test_7 = [simpleTagFactory createTagWithName:@"test_7"];
	PASimpleTag *test_8 = [simpleTagFactory createTagWithName:@"test_8"];
	PASimpleTag *test_9 = [simpleTagFactory createTagWithName:@"test_9"];
	
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
	
	tags = [[PATags alloc] init];
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

	tagger = [PATagger sharedInstance];
	[tagger setTags:tags];
	
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
			
	PAFile *file_0 = [PAFile fileWithPath:[filenames objectAtIndex:0]];
	PAFile *file_1 = [PAFile fileWithPath:[filenames objectAtIndex:0]];
	PAFile *file_2 = [PAFile fileWithPath:[filenames objectAtIndex:0]];
	
	[tagger addTags:testTags toFiles:[NSArray arrayWithObject:file_0]];
	NSArray *tagsOnFiles = [tagger tagsOnFile:file_0];
	
	STAssertEquals([testTags count],[tagsOnFiles count],@"size");

	NSEnumerator *e = [testTags objectEnumerator];
	PATag *tag;
	
	while (tag = [e nextObject])
	{
		STAssertTrue([tagsOnFiles containsObject:tag],@"tag");
	}
	
	return;
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
		[fileManager removeFileAtPath:filename handler:nil];
	}
}
	

@end
