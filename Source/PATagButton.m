#import "PATagButton.h"

@interface PATagButton (PrivateAPI)

- (float)distanceFromPoint:(NSPoint)sourcePoint to:(NSPoint)destPoint;
- (void)startDrag:(NSEvent *)event;

- (NSImage *)dragImageForMouseDownAtPoint:(NSPoint)point offsetX:(float *)offsetX y:(float *)offsetY;

@end


@implementation PATagButton
- (id)initWithTag:(NNTag*)aTag rating:(float)aRating
{
    self = [super initWithFrame:NSMakeRect(0,0,0,0)];
    if (self) 
	{		
		PATagButtonCell *cell = [[PATagButtonCell alloc] initWithTag:aTag rating:aRating];
		[self setCell:cell];
		[cell release];
		
		dropManager = [PADropManager sharedInstance];
		[self registerForDraggedTypes:[dropManager handledPboardTypes]];
				
		[self setBezelStyle:PATagBezelStyle];
		[self setButtonType:PAMomentaryLightButton];
    }
    return self;
}

/**
should be overridden according to apple docs
 */
+ (Class) cellClass
{
    return [PATagButtonCell class];
}

#pragma mark functionality
- (NNTag*)genericTag
{
	return [[self cell] genericTag];
}

- (void)setGenericTag:(NNTag*)aTag
{
	[[self cell] setGenericTag:aTag];
}

#pragma mark accessors
- (void)setRating:(float)aRating
{
	[[self cell] setRating:aRating];
}

#pragma mark drop support
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{	
	// Discard dragging from tag button to tag button
	if([[sender draggingSource] isMemberOfClass:[self class]])
		return NSDragOperationNone;
		
	NSDragOperation dragOp =  [dropManager performedDragOperation:[sender draggingPasteboard]];
	
	if (dragOp != NSDragOperationNone)
	{
		[[self cell] setHovered:YES];
		[self setNeedsDisplay:YES];
	}
	
	return dragOp;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
	[[self cell] setHovered:NO];
	[self setNeedsDisplay];
} 

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    return YES;
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender
{	
	[[self cell] setHovered:NO];
	[self setNeedsDisplay];
	
	NSArray *objects = [dropManager handleDrop:[sender draggingPasteboard]];
	[objects makeObjectsPerformSelector:@selector(addTag:) withObject:[self genericTag]];
}


#pragma mark Drag Support
- (void)mouseDown:(NSEvent *)theEvent
{
	// Highlight self
	[[self cell] setPressed:YES];
	[self setNeedsDisplay];

	BOOL                dragActive = YES;
	BOOL				dragStarted = NO;
	NSPoint             location = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	NSPoint				mouseDownLocation = location;
	NSEvent*            event = NULL;
	NSWindow            *targetWindow = [self window];
	NSAutoreleasePool   *myPool = [[NSAutoreleasePool alloc] init];

	while (dragActive) {
		event = [targetWindow nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)
										  untilDate:[NSDate distantFuture]
							                 inMode:NSEventTrackingRunLoopMode
						                	dequeue:YES];
		if(!event)
			continue;
			
		location = [self convertPoint:[event locationInWindow] fromView:nil];
		
		switch ([event type]) {		
			case NSLeftMouseDragged:				
				if(!dragStarted && [self distanceFromPoint:mouseDownLocation to:location] > 4.0)
				{
					dragStarted = YES;
					[self startDrag:theEvent];					
				}
				break;				
				
			case NSLeftMouseUp:
				dragActive = NO;
				
				[targetWindow discardEventsMatchingMask:NSAnyEventMask beforeEvent:event];
												
				[[self cell] setPressed:NO];
				
				NSPoint mouseLocation = [[self window] mouseLocationOutsideOfEventStream];
				NSPoint newLocation = [self convertPoint:mouseLocation fromView:nil];
				
				// Hover self if our mouse is still within our bounds
				if(NSPointInRect(newLocation,[self bounds]))
					[[self cell] setHovered:YES];
				else
					[[self cell] setHovered:NO];
				
				[self setNeedsDisplay];
				
				// Perform click action
				if(!dragStarted)
					[[self target] performSelector:[self action] withObject:self];
					
				break;
				
			default:
				break;
		}
	}

	[myPool release];
}

- (float)distanceFromPoint:(NSPoint)sourcePoint to:(NSPoint)destPoint
{
	float dx = sourcePoint.x - destPoint.x;
	float dy = sourcePoint.y - destPoint.y;
	return sqrt(dx * dx + dy * dy);
}

- (void)startDrag:(NSEvent *)event
{	
	NSString *smartFolder = [PASmartFolder smartFolderFilenameForTag:[self genericTag]];

	NSMutableArray *fileList = [NSMutableArray arrayWithObject:smartFolder];

	NSPasteboard *pboard = [NSPasteboard pasteboardWithName:NSDragPboard]; 
	[pboard declareTypes:[NSArray arrayWithObject:NSFilenamesPboardType] owner:nil];
	[pboard setPropertyList:fileList forType:NSFilenamesPboardType];
	
	// Click point
	NSPoint dragPoint = [self convertPoint:[event locationInWindow] fromView:nil];
	
	// Determine drag image
	float offsetX, offsetY;
	NSImage *image = [self dragImageForMouseDownAtPoint:dragPoint offsetX:&offsetX y:&offsetY];
		
	// Drag point
	dragPoint.x -= offsetX;
	dragPoint.y += offsetY;

	// we want to make the image a little bit transparent so the user can see where
    // they're dragging to
    NSImage *dragImage = [[[NSImage alloc] initWithSize:[image size]] autorelease]; 
    [dragImage lockFocus]; 
    [image dissolveToPoint:NSMakePoint(0,0) fraction:0.5]; 
    [dragImage unlockFocus];

	[self dragImage:dragImage 
				 at:dragPoint 
			 offset:NSZeroSize
			  event:event 
		 pasteboard:pboard 
			 source:self 
		  slideBack:YES];
	
	// Delete smart folder from temp dir
	[PASmartFolder removeSmartFolderForTag:[self genericTag]];
	
	// Fire a custom mouse up event to break tracking loop as this is not done
	// by dragImage automatically...
	NSEvent *theEvent = [event copy];	
	NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
	
	NSEvent *mouseUpEvent = [NSEvent mouseEventWithType:NSLeftMouseUp
											   location:[theEvent locationInWindow]
										  modifierFlags:[theEvent modifierFlags]
										      timestamp:[date timeIntervalSinceNow]
										   windowNumber:[theEvent windowNumber]
												context:[theEvent context]
										    eventNumber:[theEvent eventNumber] + 100
											 clickCount:[theEvent clickCount]
											   pressure:[theEvent pressure]];
		  
	[[self window] postEvent:mouseUpEvent atStart:YES];
					
	[theEvent autorelease];
}

- (NSImage *)dragImageForMouseDownAtPoint:(NSPoint)point offsetX:(float *)offsetX y:(float *)offsetY
{
	NSRect bounds = [self bounds];

	NSImage *image = [[NSImage alloc] initWithSize:bounds.size];
	
	[image lockFocus];
	[self drawRect:bounds];	
	[image unlockFocus];
	
	// Determine mouse offset relative to our bounds
	*offsetX = point.x - bounds.origin.x;
	*offsetY = bounds.size.height - (point.y - bounds.origin.y);
	
	return [image autorelease];
}

- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)flag
{
    return NSDragOperationCopy;
}

@end
