#import "TaggerController.h"

@implementation TaggerController

- (id)initWithWindowNibName:(NSString*)windowNibName tags:(PATags*)newTags
{
	if (self = [super initWithWindowNibName:windowNibName])
	{
		typeAheadFind = [[PATypeAheadFind alloc] initWithTags:newTags];
		tags = newTags;
	}
	return self;
}

- (void)awakeFromNib
{
	NSLog(@"im awake");
}

- (void)dealloc
{
	[tags release];
	[typeAheadFind release];
	[files release];
	[super dealloc];
}

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

- (NSArray *)tokenField:(NSTokenField *)tokenField shouldAddObjects:(NSArray *)tokens atIndex:(unsigned)index
{
	NSLog([tokens description]);
	return tokens;
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
	NSLog(@"change: %@",[tagField objectValue]);
}

@end