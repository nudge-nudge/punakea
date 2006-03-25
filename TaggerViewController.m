#import "TaggerViewController.h"

@interface TaggerViewController (PrivateAPI)

- (void)updateTagsOnFile;

@end

@implementation TaggerViewController

- (void)awakeFromNib 
{
	tagger = [PATagger sharedInstance];
	
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

#pragma mark click targets
- (void)addPopularTag 
{
	if ([[popularTags selectedObjects] count] > 0)
	{
		PATag *tag = [[popularTags selectedObjects] objectAtIndex:0];
		[fileTags addObject:tag];
		[self updateTagsOnFile];
	}
}
	
- (void)addRecentTag
{
	if ([[recentTags selectedObjects] count] > 0)
	{
		PATag *tag = [[recentTags selectedObjects] objectAtIndex:0];
		[fileTags addObject:tag];
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

- (void)updateTagsOnFile 
{
	NSString *file = [filePath stringValue];
	
	//only update if there is a file
	if (![file isEqualToString:@""])
	{
		NSEnumerator *e = [[fileTags arrangedObjects] objectEnumerator];
		PATag *tag;
		
		while (tag = [e nextObject])
			[tag incrementUseCount];	
		
		NSLog(@"trying to write %@ to %@",tags,[filePath stringValue]);
		[tagger writeTagsToFile:[fileTags arrangedObjects] filePath:[filePath stringValue]];
	}
}

@end
