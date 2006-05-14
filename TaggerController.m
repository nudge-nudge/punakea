#import "TaggerController.h"

@implementation TaggerController

#pragma mark init + dealloc
- (id)initWithWindowNibName:(NSString*)windowNibName tags:(PATags*)newTags
{
	if (self = [super initWithWindowNibName:windowNibName])
	{
		typeAheadFind = [[PATypeAheadFind alloc] initWithTags:newTags];
		tags = newTags;
		tagger = [PATagger sharedInstance];
		currentCompleteTagsInField = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[currentCompleteTagsInField release];
	[tags release];
	[typeAheadFind release];
	[files release];
	[super dealloc];
}

#pragma mark accessors
- (NSMutableArray*)files
{
	return files;
}

- (void)setFiles:(NSMutableArray*)newFiles
{
	[newFiles retain];
	[files release];
	files = newFiles;
	
	//get tags for files and show them in the tagField
	NSArray *fileTags = [tags simpleTagsForFilesAtPaths:newFiles];

	NSMutableArray *tagsForTagField = [NSMutableArray array];
	
	NSEnumerator *e = [fileTags objectEnumerator];
	PASimpleTag *tag;
	
	while (tag = [e nextObject])
	{
		[tagsForTagField addObject:[tag name]];
	}
	
	[tagField setObjectValue:tagsForTagField];
	currentCompleteTagsInField = [[tagField objectValue] copy];
}

#pragma mark tokenField delegate

- (NSArray *)tokenField:(NSTokenField *)tokenField 
completionsForSubstring:(NSString *)substring 
		   indexOfToken:(int)tokenIndex 
	indexOfSelectedItem:(int *)selectedIndex
{
	[typeAheadFind setPrefix:substring];
	
	NSMutableArray *results = [NSMutableArray array];
	
	NSEnumerator *e = [[typeAheadFind matchingTags] objectEnumerator];
	PASimpleTag *tag;
	
	while (tag = [e nextObject])
	{
		[results addObject:[tag name]];
	}
	
	return results;
}

- (NSArray *)tokenField:(NSTokenField *)tokenField 
	   shouldAddObjects:(NSArray *)tokens 
				atIndex:(unsigned)index
{
	NSArray *newTags = [tags simpleTagsForNames:tokens];
	[tagger addTags:newTags ToFiles:files];
	currentCompleteTagsInField = [[tagField objectValue] copy];
	return tokens;
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
		PASimpleTag *tag;
		
		while (tag = [e nextObject])
		{
			if (![[tagField objectValue] containsObject:tag])
			{
				[deletedTags addObject:[tags simpleTagForName:tag]];
			}
		}
		
		// remove the deleted tags from all files
		[tagger removeTags:deletedTags fromFiles:files];
		currentCompleteTagsInField = [[tagField objectValue] copy];
	}
}

@end