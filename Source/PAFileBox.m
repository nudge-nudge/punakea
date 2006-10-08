#import "PAFileBox.h"

@implementation PAFileBox

- (void)awakeFromNib
{
	dropManager = [PADropManager sharedInstance];
	
	[self registerForDraggedTypes:[dropManager handledPboardTypes]];
	highlight = NO;
}

- (void)dealloc
{
    [self unregisterDraggedTypes];
    [super dealloc];
}

#pragma mark accessors

- (void)setFiles:(NSArray*)fileArray
{
	[fileArray mutableCopy];
	[files release];
	files = fileArray;
}

- (NSMutableArray*)files
{
	return files;
}

- (void)setFileIcon:(NSImage*)newIcon 
{
	[newIcon setSize:NSMakeSize(64,64)];
	[self setImage:newIcon];
}

- (NSImage*)fileIcon
{
	return [self image];
}

#pragma mark drap & drop stuff
//code of cocoadevcentral tutorial

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
	[[self window] mouseEvent];
	
	return [dropManager performedDragOperation:[sender draggingPasteboard]];
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
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
	highlight = NO;
    [self setNeedsDisplay:YES];
}

@end
