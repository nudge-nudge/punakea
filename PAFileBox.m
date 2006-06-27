#import "PAFileBox.h"

@implementation PAFileBox

- (id)initWithFrame:(NSRect)frameRect
{
	if (self = [super initWithFrame:frameRect]) {
		[self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType,nil]];
		highlight = NO;
	}
	return self;
}

- (void)dealloc
{
    [self unregisterDraggedTypes];
    [super dealloc];
}

- (void)drawRect:(NSRect)rect
{
	//draw the background
	if (highlight) 
		[[NSColor lightGrayColor] set];
	else
		[[NSColor whiteColor] set];
	
	NSRect bounds = [self bounds];
	[NSBezierPath fillRect:bounds];
	
	//draw the image, inherited
	[super drawRect:rect];
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
	//TODO do the resize stuff here?
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
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
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
	NSPasteboard *paste = [sender draggingPasteboard];
	
	[self setFiles:[paste propertyListForType:@"NSFilenamesPboardType"]];
	
	[self setFileIcon:[[NSWorkspace sharedWorkspace] iconForFiles:files]];
	
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
