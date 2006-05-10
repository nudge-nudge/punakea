#import "TaggerController.h"

@implementation TaggerController

- (id)initWithWindowNibName:(NSString*)windowNibName tags:(PATags*)newTags
{
	if (self = [super initWithWindowNibName:windowNibName])
	{
		NSLog(@"blub");
		typeAheadFind = [[PATypeAheadFind alloc] initWithTags:newTags];
	}
	return self;
}

- (void)dealloc
{
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
}

#pragma mark tokenField delegate

- (NSArray *)tokenField:(NSTokenField *)tokenField 
completionsForSubstring:(NSString *)substring 
		   indexOfToken:(int)tokenIndex 
	indexOfSelectedItem:(int *)selectedIndex
{
	NSLog(@"called");
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

@end