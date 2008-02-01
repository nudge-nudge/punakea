//
//  TagAutoCompleteController.m
//  punakea
//
//  Created by Daniel on 01.02.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TagAutoCompleteController.h"


@implementation TagAutoCompleteController

#pragma mark init + dealloc
- (id)init
{
	if (self = [super init])
	{			
		currentCompleteTagsInField = [[NNSelectedTags alloc] init];		
		globalTags = [NNTags sharedTags];		
		typeAheadFind = [[PATypeAheadFind alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[currentCompleteTagsInField release];
	[typeAheadFind release];
	
	[super dealloc];
}


#pragma mark Tag Field Delegate
-    (NSArray *)tokenField:(NSTokenField *)tokenField 
   completionsForSubstring:(NSString *)substring 
			  indexOfToken:(int)tokenIndex 
	   indexOfSelectedItem:(int *)selectedIndex
{
	NSMutableArray *results = [NSMutableArray array];
	
	NSEnumerator *e = [[typeAheadFind tagsForPrefix:substring] objectEnumerator];
	NNSimpleTag *tag;
	
	while (tag = [e nextObject])
	{
		[results addObject:[tag name]];
	}
	
	return results;
}

- (NSArray *)tokenField:(NSTokenField *)tokenField 
	   shouldAddObjects:(NSArray *)tokens 
				atIndex:(unsigned)idx
{
	[currentCompleteTagsInField addObjectsFromArray:tokens];
	
	return tokens;
}

- (NSString *)tokenField:(NSTokenField *)tokenField displayStringForRepresentedObject:(id)representedObject
{
	return [representedObject name];
}

- (NSString *)tokenField:(NSTokenField *)tokenField editingStringForRepresentedObject:(id)representedObject
{
	return [representedObject name];
}

- (id)tokenField:(NSTokenField *)tokenField representedObjectForEditingString:(NSString *)editingString
{
	if (editingString && [editingString isNotEqualTo:@""])
		return [globalTags tagForName:editingString create:YES];
	else
		return nil;
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
	// only do something if a tag has been completely deleted
	// adding tags is handled by ... shouldAddObjects: ...
	
	// Important: If one tag is present and selected and we type in a new one, the following operator
	// needs to be LESS THAN, not LESS
	
	if ([[tagField objectValue] count] <= [currentCompleteTagsInField count])
	{		
		// look for deleted tags
		NSMutableArray *deletedTags = [NSMutableArray array];
		
		NSEnumerator *e = [currentCompleteTagsInField objectEnumerator];
		NNSimpleTag *tag;
		
		while (tag = [e nextObject])
		{
			if (![[tagField objectValue] containsObject:tag])
			{
				[deletedTags addObject:tag];
			}
		}
		
		// now remove the tags to be deleted from currentCompleteTagsInField - to keep in sync with tagField
		[currentCompleteTagsInField removeObjectsInArray:deletedTags];
	}
}


#pragma mark Accessors
- (NSTokenField *)tagField
{
	return tagField;
}

- (NNSelectedTags *)currentCompleteTagsInField
{
	return currentCompleteTagsInField;
}

- (void)setCurrentCompleteTagsInField:(NNSelectedTags *)newTags
{	
	[currentCompleteTagsInField release];
	currentCompleteTagsInField = [newTags retain];
}

@end
