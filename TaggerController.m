#import "TaggerController.h"

@interface TaggerController (PrivateAPI)

/**
adds tag to tagField (use from "outside")
 @param tag tag to add 
 */
- (void)addTagToField:(PASimpleTag*)tag;

/**
called when tags have changed, updates query
 */
- (void)tagsHaveChanged;

@end

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
		NSSortDescriptor *popularDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"absoluteRating" ascending:NO] autorelease];
		popularTagsSortDescriptors = [[NSArray alloc] initWithObjects:popularDescriptor,nil];
		
		filesHaveChanged = NO;
		
		// related tags stuff
		query = [[NSMetadataQuery alloc] init];
		relatedTags = [[PARelatedTags alloc] initWithQuery:query tags:tags];
	}
	return self;
}

- (void)awakeFromNib
{
	//nothing yet
}

- (void)dealloc
{
	[relatedTags release];
	[query release];
	[popularTagsSortDescriptors release];
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
	
	// get tags for files and show them in the tagField
	NSArray *fileTags = [tags simpleTagsForFilesAtPaths:newFiles];
	[tagField setObjectValue:fileTags];
	[self setCurrentCompleteTagsInField:[[tagField objectValue] mutableCopy]];
	
	// set helper flag so that shouldAddObjects
	// doesn't write tags
	filesHaveChanged = YES;
}

- (NSMutableArray*)currentCompleteTagsInField
{
	return currentCompleteTagsInField;
}

- (void)setCurrentCompleteTagsInField:(NSMutableArray*)newTags
{
	[newTags retain];
	[currentCompleteTagsInField release];
	currentCompleteTagsInField = newTags;
	[self tagsHaveChanged];
}

#pragma mark functionality
- (void)addTagToField:(PASimpleTag*)tag
{
	// when the user started typing some stuff, and a new tag is added,
	// the temporary typing is discarded, and the new tag added instead.
	// is this good behaviour? TODO
	NSMutableArray *newContent = [[[tagField objectValue] mutableCopy] autorelease];
	
	// add tag to the last position
	[newContent insertObject:tag atIndex:[currentCompleteTagsInField count]];
	[tagField setObjectValue:newContent];
}

//TODO same method as in controller .. put together!
- (void)tagsHaveChanged
{
	//stop an active query
	if ([query isStarted]) 
		[query stopQuery];
	
	// construct NSPredicate
	if ([currentCompleteTagsInField count] > 0)
	{
		NSMutableString *queryString = [NSMutableString stringWithString:@""];
		
		NSEnumerator *e = [currentCompleteTagsInField objectEnumerator];
		PATag *tag;
		
		if (tag = [e nextObject])
		{
			NSString *anotherTagQuery = [NSString stringWithFormat:@"(%@)",[tag query]];
			[queryString appendString:anotherTagQuery];
		}
		
		while (tag = [e nextObject]) 
		{
			NSString *anotherTagQuery = [NSString stringWithFormat:@" && (%@)",[tag query]];
			[queryString appendString:anotherTagQuery];
		}
		
		NSPredicate *predicate = [NSPredicate predicateWithFormat:queryString];
		NSLog(@"predicate: %@",predicate);
		[query setPredicate:predicate];
		[query startQuery];
	}
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
	if (!filesHaveChanged)
	{
		[tagger addTags:tokens ToFiles:files];
		filesHaveChanged = NO;
	}
	[currentCompleteTagsInField addObjectsFromArray:tokens];
	// needs to be called manually because setter of currentCompleteTagsInField is not called
	[self tagsHaveChanged];
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
	return [tags simpleTagForName:editingString];
}

- (NSTokenStyle)tokenField:(NSTokenField *)tokenField styleForRepresentedObject:(id)representedObject
{
	//TODO don't call this every time - cache it
	NSDictionary *tagDict = [tags simpleTagNamesWithCountForFilesAtPaths:files];
	
	int count = [[tagDict objectForKey:[representedObject name]] intValue];
	
	if (count > 1)
	{
		NSLog(@"%@: %i => fat",representedObject,count);
		return NSRoundedTokenStyle;
	}
	else
	{
		NSLog(@"%@: %i => slim",representedObject,count);
		return NSRoundedTokenStyle;
	}		 
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
				[deletedTags addObject:tag];
			}
		}
		
		// remove the deleted tags from all files
		[tagger removeTags:deletedTags fromFiles:files];
		[self setCurrentCompleteTagsInField:[[tagField objectValue] mutableCopy]];
	}
}

#pragma mark clicks in table
- (IBAction)addPopularTag
{
	NSArray *selection = [popularTags selectedObjects];
	
	if ([selection count] == 1)
	{
		[self addTagToField:[selection objectAtIndex:0]];
	}
}
@end