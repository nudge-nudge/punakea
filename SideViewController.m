#import "SideViewController.h"

@interface SideViewController (PrivateAPI)

- (void)addTagToFileTags:(PATag*)tag;
- (void)updateTagsOnFile;

@end

@implementation SideViewController

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
	
	//observe files on fileBox
	[fileBox addObserver:self forKeyPath:@"files" options:0 context:NULL];
	
	//drag & drop
	[popularTagsTable registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
	popularTagTableController = [[PATableViewDropController alloc] initWithTags:popularTags];
	[popularTagsTable setDataSource:popularTagTableController];
	
	[recentTagsTable registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
	recentTagTableController = [[PATableViewDropController alloc] initWithTags:recentTags];
	[recentTagsTable setDataSource:recentTagTableController];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object 
                        change:(NSDictionary *)change
                       context:(void *)context
{
	if ([keyPath isEqual:@"files"]) 
		[self newFilesHaveBeenDropped];
}

#pragma mark tag field delegates
//TODO only on hitting enter!!!
/* deprecated - use taggerController instead
- (void)controlTextDidEndEditing:(NSNotification *)aNotification
{
	NSString *tmpString = [tagField stringValue];
	
	//only if there is any text in the field
	if (![tmpString isEqualToString:@""])
	{
		PASimpleTag *tag = [[controller tags] simpleTagForName:tmpString];

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
		
		NSLog(@"trying to write %@ to %@",[controller tags],file);
		[tagger writeTagsToFile:[fileTags arrangedObjects] filePath:file];
	}
}
*/

/**
action called on dropping files to FileBox
 */
- (void)newFilesHaveBeenDropped
{
	//open tagger window
	TaggerController *taggerController = [[TaggerController alloc] initWithWindowNibName:@"Tagger" tags:[controller tags]];
	[taggerController showWindow:nil];
	[taggerController setFiles:[fileBox files]];
}

@end
