//
//  PATagAutocompleteWindowController.m
//  punakea
//
//  Created by Daniel on 04.05.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PATagAutocompleteWindowController.h"


@interface PATagAutocompleteWindowController (PrivateAPI)

- (void)commonInit;

@end



@implementation PATagAutocompleteWindowController

#pragma mark init + dealloc
- (id)initWithWindow:(NSWindow *)window
{
	if (self = [super initWithWindow:window])
	{			
		[self commonInit];
	}
	return self;
}

- (id)initWithWindowNibName:(NSString *)windowNibName
{
	if (self = [super initWithWindowNibName:windowNibName])
	{			
		[self commonInit];
	}
	return self;
}

- (void)commonInit
{
	currentCompleteTagsInField = [[NNSelectedTags alloc] init];
	
	globalTags = [NNTags sharedTags];
	
	typeAheadFind = [[PATypeAheadFind alloc] init];
}

- (void)dealloc
{
	[typeAheadFind release];
	[currentCompleteTagsInField release];
	[super dealloc];
}


#pragma mark Misc
- (void)validateConfirmButton
{
	if(!confirmButton)
		return;
	
	[confirmButton setEnabled:([currentCompleteTagsInField count] > 0)];
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
	
	[self validateConfirmButton];
	
	// everything will be added
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
		return [globalTags createTagForName:editingString];
	else
		return nil;
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
	// only do something if a tag has been completely deleted
	// adding tags is handled by ... shouldAddObjects: ...
	if ([[tagField objectValue] count] < [currentCompleteTagsInField count])
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
	
	[self validateConfirmButton];
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

- (NSString *)restDisplayString
{
	return restDisplayString;
}

- (NNTags *)globalTags
{
	return globalTags;
}

- (PATypeAheadFind *)typeAheadFind
{
	return typeAheadFind;
}

@end
