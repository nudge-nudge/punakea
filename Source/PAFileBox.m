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

- (void)setObjects:(NSArray*)objectArray
{
	[objects release];
	objects = [objectArray mutableCopy];
}

- (NSMutableArray*)objects
{
	return objects;
}

#pragma mark drap & drop stuff
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
	// check if sender should be ignored
	if(![dropManager acceptsSender:[sender draggingSource]])
		return NSDragOperationNone;
	
	NSEvent *currentEvent = [NSApp currentEvent];
    unsigned flags = [currentEvent modifierFlags];
    if (flags & NSAlternateKeyMask)
		[dropManager setAlternateState:YES];
	else 
		[dropManager setAlternateState:NO];	
	
	[[self window] mouseEvent];
	[self setImage:[NSImage imageNamed:@"drop_highlight"]];
	
	return [dropManager performedDragOperation:[sender draggingPasteboard]];
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
	[self setImage:[NSImage imageNamed:@"drop"]];
	[[self window] mouseEvent];
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender
{
	// check if sender should be ignored
	if(![dropManager acceptsSender:[sender draggingSource]])
		return NSDragOperationNone;
	
	NSEvent *currentEvent = [NSApp currentEvent];
    unsigned flags = [currentEvent modifierFlags];
    if (flags & NSAlternateKeyMask)
		[dropManager setAlternateState:YES];
	else 
		[dropManager setAlternateState:NO];
	
	return [dropManager performedDragOperation:[sender draggingPasteboard]];
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
	//[[[self window] delegate] appShouldStayFront];
	
	NSArray *newObjects = [dropManager handleDrop:[sender draggingPasteboard]];
	[self setObjects:newObjects];
	
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
