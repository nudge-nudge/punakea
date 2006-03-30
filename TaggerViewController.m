#import "TaggerViewController.h"

@interface TaggerViewController (PrivateAPI)

- (void)addTagToFileTags:(PATag*)tag;
- (void)updateTagsOnFile;

@end

@implementation TaggerViewController

- (void)awakeFromNib 
{
	tagger = [PATagger sharedInstance];
	factory = [[PASimpleTagFactory alloc] init];
	
	//TODO can be done from IB ... do this!
	//init sorting
	NSSortDescriptor *popularDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"absoluteRating" ascending:NO] autorelease];
	NSArray *popularSortDescriptors = [NSArray arrayWithObject:popularDescriptor];
	[popularTags setSortDescriptors:popularSortDescriptors];
	
	//TODO asc or desc?!
	NSSortDescriptor *recentDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"lastUsed" ascending:NO] autorelease];
	NSArray *recentSortDescriptors = [NSArray arrayWithObject:recentDescriptor];
	[recentTags setSortDescriptors:recentSortDescriptors];
}

#pragma mark tag field delegates
//TODO only on hitting enter!!!
- (void)controlTextDidEndEditing:(NSNotification *)aNotification
{
	//only if there is any text in the field
	if ([tagField stringValue] != @"")
	{
		PATag *tag = [factory createTagWithName:[tagField stringValue]];
		
		//if the tag is new, add it to the global tag controller
		if (![[tags arrangedObjects] containsObject:tag])
			[tags addObject:tag];

		[self addTagToFileTags:tag];
		[self updateTagsOnFile];
	}
}

#pragma mark click targets
- (void)addPopularTag 
{
	if ([[popularTags selectedObjects] count] > 0)
	{
		PATag *tag = [[popularTags selectedObjects] objectAtIndex:0];
		[self addTagToFileTags:tag];
		[self updateTagsOnFile];
	}
}
	
- (void)addRecentTag
{
	if ([[recentTags selectedObjects] count] > 0)
	{
		PATag *tag = [[recentTags selectedObjects] objectAtIndex:0];
		[self addTagToFileTags:tag];
		[self updateTagsOnFile];
	}
}

- (void)removeTagFromFile
{
	if ([[fileTags selectedObjects] count] > 0)
	{
		PATag *tag = [[fileTags selectedObjects] objectAtIndex:0];
		[fileTags removeObject:tag];
		[self updateTagsOnFile];
	}
}

- (void)addTagToFileTags:(PATag*)tag
{
	if (![[fileTags arrangedObjects] containsObject:tag])
		[fileTags addObject:tag];
}

/**
adds tags from fileTags to all files in the file box
 */
- (void)updateTagsOnFile 
{
	NSArray *files = [fileBox files];
	
	NSEnumerator *fileEnumerator = [files objectEnumerator];
	NSString *file;
	
	while (file = [fileEnumerator nextObject])
	{
		NSEnumerator *e = [[fileTags arrangedObjects] objectEnumerator];
		PATag *tag;
		
		while (tag = [e nextObject])
			[tag incrementUseCount];
		
		NSLog(@"trying to write %@ to %@",tags,file);
		[tagger writeTagsToFile:[fileTags arrangedObjects] filePath:file];
	}
}

@end
