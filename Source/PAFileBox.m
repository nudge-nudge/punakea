#import "PAFileBox.h"

@implementation PAFileBox

- (void)awakeFromNib
{
	dropManager = [[PADropManager alloc] init];
	
	[self registerForDraggedTypes:[dropManager handledPboardTypes]];
	highlight = NO;
}

- (void)dealloc
{
    [self unregisterDraggedTypes];
	[dropManager release];
    [super dealloc];
}

#pragma mark accessors

- (void)setFiles:(NSMutableArray*)fileArray
{
	[fileArray retain];
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
	
	return NSDragOperationEvery;
	
	/*
	
    if ((NSDragOperationGeneric & [sender draggingSourceOperationMask]) 
		== NSDragOperationGeneric)
    {
        //this means that the sender is offering the type of operation we want
        //return that we want the NSDragOperationGeneric operation that they 
		//are offering
		highlight = YES;
		[self setNeedsDisplay:YES];
        return NSDragOperationGeneric;
    }
    else
    {
        //since they aren't offering the type of operation we want, we have 
		//to tell them we aren't interested
        return NSDragOperationNone;
    }
	 */
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
	[[self window] mouseEvent];

	highlight = NO;
	[self setNeedsDisplay:YES];
}

- (void)draggingEnded:(id <NSDraggingInfo>)sender
{
	highlight = NO;
	[self setNeedsDisplay:YES];
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
    return YES;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	NSDictionary *dropResult = [dropManager handleDrop:[sender draggingPasteboard]];
	[self setFiles:[dropResult objectForKey:@"files"]];
	[self setFileIcon:[dropResult objectForKey:@"icon"]];
			
	[self setNeedsDisplay:YES];
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
