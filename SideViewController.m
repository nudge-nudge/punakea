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
	[fileBox addObserver:self
			  forKeyPath:@"files"
				 options:0
				 context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object 
                        change:(NSDictionary *)change
                       context:(void *)context
{
	if ([keyPath isEqual:@"files"]) 
		[self newFileHaveBeenDropped];
}

#pragma mark tag field delegates
//TODO only on hitting enter!!!
- (void)controlTextDidEndEditing:(NSNotification *)aNotification
{
	NSString *tmpString = [tagField stringValue];
	
	//only if there is any text in the field
	if (![tmpString isEqualToString:@""])
	{
		PASimpleTag *tag = [controller simpleTagForName:tmpString];

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
adds tags from fileTags to all files in the file box TODO
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
		
		NSLog(@"trying to write %@ to %@",[controller tags],file);
		[tagger writeTagsToFile:[fileTags arrangedObjects] filePath:file];
	}
}

/**
action called on dropping files to FileBox
 */
- (void)newFileHaveBeenDropped
{
	//clear fileTags
	[fileTags removeObjects:[fileTags arrangedObjects]];
	
	NSMutableArray *newTags = [NSMutableArray array];
	
	//TODO multiple files? hmmm ...
	NSEnumerator *e = [[fileBox files] objectEnumerator];
	NSString *file;
	
	while (file = [e nextObject])
	{
		NSArray *tmpTags = [tagger getTagsForFile:file];
		
		NSEnumerator *tagEnumerator = [tmpTags objectEnumerator];
		PATag *tag;
		
		while (tag = [tagEnumerator nextObject])
		{
			if (![newTags containsObject:tag])
				[newTags addObject:tag];
		}
	}
	
	[fileTags addObjects:newTags];
}
@end
