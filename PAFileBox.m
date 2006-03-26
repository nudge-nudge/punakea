#import "PAFileBox.h"

@implementation PAFileBox

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
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

- (void)setFiles:(NSArray*)fileArray
{
	[fileArray retain];
	[files release];
	files = fileArray;
}

- (NSArray*)files
{
	return files;
}

- (void)setFileIcon:(NSImage*)newIcon 
{
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
	
	[self setNeedsDisplay:YES];    //redraw us with the new image
    return YES;
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender
{	
	//TODO no good code, put this elsewhere
	//clear fileTags
	[fileTags removeObjects:[fileTags arrangedObjects]];
	
	PATagger *tagger = [PATagger sharedInstance];
	NSMutableArray *tags = [NSMutableArray array];
	
	//TODO multiple files? hmmm ...
	NSEnumerator *e = [files objectEnumerator];
	NSString *file;
	
	while (file = [e nextObject])
	{
		NSArray *tmpTags = [tagger getTagsForFile:file];
		
		NSEnumerator *tagEnumerator = [tmpTags objectEnumerator];
		PATag *tag;
		
		while (tag = [tagEnumerator nextObject])
		{
			if (![tags containsObject:tag])
				[tags addObject:tag];
		}
	}
	
	[fileTags addObjects:tags];
	
    highlight = NO;
    [self setNeedsDisplay:YES];
}

@end
