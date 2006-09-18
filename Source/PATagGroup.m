//
//  PATagGroup.m
//  punakea
//
//  Created by Johannes Hoffart on 18.09.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PATagGroup.h"

@interface PATagGroup (PrivateAPI)

- (void)setGroupedTags:(NSMutableArray*)someTags;
- (void)setSortDescriptors:(NSArray*)someSortDescriptors;

@end

@implementation PATagGroup

- (id)init
{
	if (self = [super init])
	{
		// TODO make user definable ... needs to adjust sidebar size and stuff ...
		maxSize = 8;
		tags = [[PATagger sharedInstance] tags];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tagsHaveChanged) name:nil object:tags];
	}
	
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[groupedTags release];
	[super dealloc];
}

- (NSMutableArray*)groupedTags
{
	return groupedTags;
}

- (void)setGroupedTags:(NSMutableArray*)someTags
{
	[someTags retain];
	[groupedTags release];
	groupedTags = someTags;
}

- (void)setSortDescriptors:(NSArray*)someSortDescriptors
{
	[someSortDescriptors retain];
	[sortDescriptors release];
	sortDescriptors = someSortDescriptors;
}

#pragma mark functionality
- (void)tagsHaveChanged
{
	NSMutableArray *tagsCopy = [[tags tags] mutableCopy];
	[tagsCopy sortUsingDescriptors:sortDescriptors];
	
	NSMutableArray *newGroup = [NSMutableArray array];
	
	for (int i=0;i<maxSize;i++)
	{
		PATag *tag = [tagsCopy objectAtIndex:i];
		[newGroup addObject:[tags tagForName:[tag name]]];
	}
	
	[self setGroupedTags:newGroup];
	
	[tagsCopy release];
}

@end
