#import "PATagButton.h"

@implementation PATagButton
- (id)initWithTag:(PATag*)aTag rating:(float)aRating
{
    self = [super initWithFrame:NSMakeRect(0,0,0,0)];
    if (self) 
	{		
		PATagButtonCell *cell = [[PATagButtonCell alloc] initWithTag:aTag rating:aRating];
		[self setCell:cell];
		[cell release];
		
		dropManager = [PADropManager sharedInstance];
		[self registerForDraggedTypes:[dropManager handledPboardTypes]];
		
		tagger = [PATagger sharedInstance];
		
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
- (PATag*)fileTag
{
	return [[self cell] fileTag];
}

- (void)setFileTag:(PATag*)aTag
{
	[[self cell] setFileTag:aTag];
}

#pragma mark accessors
- (void)setRating:(float)aRating
{
	[[self cell] setRating:aRating];
}

#pragma mark drop support
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
	[[self cell] setHovered:YES];
	[self setNeedsDisplay];
	
	return NSDragOperationCopy;
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
	
	
	NSArray *files = [dropManager handleDrop:[sender draggingPasteboard]];
	[tagger addTags:[NSArray arrayWithObject:[[self cell] fileTag]] toFiles:files];
}

@end
