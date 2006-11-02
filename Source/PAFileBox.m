#import "PAFileBox.h"

@implementation PAFileBox

- (void)awakeFromNib
{
	dropManager = [PADropManager sharedInstance];
	
	[self registerForDraggedTypes:[dropManager handledPboardTypes]];
}

- (void)dealloc
{
    [self unregisterDraggedTypes];
    [super dealloc];
}

#pragma mark accessors

- (void)setFiles:(NSArray*)fileArray
{
	[files release];
	files = [fileArray mutableCopy];
}

- (NSMutableArray*)files
{
	return files;
}

#pragma mark drap & drop stuff
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
	[[self window] mouseEvent];
	[self setImage:[NSImage imageNamed:@"drop_highlight"]];
	
	return [dropManager performedDragOperation:[sender draggingPasteboard]];
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
	[self setImage:[NSImage imageNamed:@"drop"]];
	[[self window] mouseEvent];
}

- (void)draggingEnded:(id <NSDraggingInfo>)sender
{
	//nothin
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
    return YES;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	NSArray *newFiles = [dropManager handleDrop:[sender draggingPasteboard]];
	[self setFiles:newFiles];
	
    return YES;
}

/**
executes some interface stuff
 */
- (void)concludeDragOperation:(id <NSDraggingInfo>)sender
{	
	[self setImage:[NSImage imageNamed:@"drop"]];
}

@end
