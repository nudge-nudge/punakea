// *** D E P R E C A T E D ***
// Use TagAutoCompleteController instead.
// This class is still used in TaggerController. Needs to be replaced somewhere along the way...

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
	[currentCompleteTagsInField release];
	[typeAheadFind release];
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
		return [globalTags tagForName:editingString create:YES];
	else
		return nil;
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
	// overwritten by TaggerController.h
	NSLog(@"DO NOT USE PATagAutocompleteWindowController ANY MORE!");
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
