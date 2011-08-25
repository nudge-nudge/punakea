// Copyright (c) 2006-2011 nudge:nudge (Johannes Hoffart & Daniel Bär). All rights reserved.
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "TagAutoCompleteController.h"


@implementation TagAutoCompleteController

#pragma mark init + dealloc
- (id)init
{
	if (self = [super init])
	{			
		globalTags = [NNTags sharedTags];		

		currentCompleteTagsInField = [[NNSelectedTags alloc] init];		
		typeAheadFind = [[PATypeAheadFind alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[currentCompleteTagsInField release];
	[typeAheadFind release];
	
	NSLog(@"dealloc %@",self);
	
	[super dealloc];
}


#pragma mark Tag Field Delegate
-    (NSArray *)tokenField:(NSTokenField *)tokenField 
   completionsForSubstring:(NSString *)substring 
			  indexOfToken:(NSInteger)tokenIndex 
	   indexOfSelectedItem:(NSInteger *)selectedIndex
{
	NSMutableArray *results = [NSMutableArray array];
	
	for (NNSimpleTag *tag in [typeAheadFind tagsForPrefix:substring])
	{
		// We need to keep all characters that the user has typed in (case-sensitive!)...
		NSString *name = [NSString stringWithString:substring];
		
		// ...then append all matching suffixes
		name = [name stringByAppendingString:[[tag precomposedName] substringFromIndex:[substring length]]];
		
		[results addObject:name];
	}
	
	return results;
}

- (NSArray *)tokenField:(NSTokenField *)tokenField 
	   shouldAddObjects:(NSArray *)tokens 
				atIndex:(NSUInteger)idx
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
		return [globalTags tagForName:editingString creationOptions:NNTagsCreationOptionFull];
	else
		return nil;
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
	// adding tags is handled by tokenField:shouldAddObjects:atIndex,
	// this method handles the deletion of tags
	
	// [fieldEditor string] contains \uFFFC (OBJECT REPLACEMENT CHARACTER) for every token
	NSDictionary *userInfo = [aNotification userInfo];
	NSText *fieldEditor = [userInfo objectForKey:@"NSFieldEditor"];
	NSString *editorString = [fieldEditor string];
	
	// get a count of the tags by replacing the \ufffc occurrences
	NSString *objectReplacementCharacter = [NSString stringWithUTF8String:"\ufffc"];
	NSMutableString *mutableEditorString = [editorString mutableCopy];
	NSUInteger numberOfTokens = [mutableEditorString replaceOccurrencesOfString:objectReplacementCharacter
																	   withString:@""
																		  options:0
																			range:NSMakeRange(0, [mutableEditorString length])];
	[mutableEditorString release];
	 
	if (numberOfTokens < [currentCompleteTagsInField count])
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
