//
//  PATagManagementViewController.m
//  punakea
//
//  Created by Johannes Hoffart on 13.07.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PATagManagementViewController.h"


@implementation PATagManagementViewController

- (id)initWithNibName:(NSString*)nibName
{
	if (self = [super init])
	{
		tagger = [PATagger sharedInstance];
		tags = [tagger tags];
		
		query = [[PAQuery alloc] init];
		
		//TODO this stuff should be in the superclass!
		[NSBundle loadNibNamed:nibName owner:self];
	}
	return self;
}

- (void)dealloc
{
	[query release];
	[super dealloc];
}

#pragma mark datasource
- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [tags count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	// TODO fixed order needed
	return [[[tags tagArray] objectAtIndex:rowIndex] name];
}

#pragma mark actions
- (IBAction)removeTag:(id)sender
{
	NSIndexSet *indexes = [tableView selectedRowIndexes];
	NSArray *selectedTags = [[tags tagArray] objectsAtIndexes:indexes];
	
	NSEnumerator *selectedTagsEnumerator = [selectedTags objectEnumerator];
	PATag *tag;
	
	while (tag = [selectedTagsEnumerator nextObject])
	{
		[tagger removeTag:tag];
		[tags removeTag:tag];
	}
}		
	
@end