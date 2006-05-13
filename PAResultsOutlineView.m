#import "PAResultsOutlineView.h"


static unsigned int PAModifierKeyMask = NSShiftKeyMask | NSAlternateKeyMask | NSCommandKeyMask | NSControlKeyMask;

@implementation PAResultsOutlineView

#pragma mark Init
- (void)awakeFromNib
{
	[self setIndentationPerLevel:0.0];
	[self setIntercellSpacing:NSMakeSize(0,1)];
	[[self delegate] setOutlineView:self];
	
	// Auto-size first column
	NSRect bounds = [self bounds];
	[[[self tableColumns] objectAtIndex:0] setWidth:bounds.size.width];	
	
	// TODO: Double-click
	[self setTarget:[self delegate]];
	[self setDoubleAction:@selector(doubleAction:)];
}


#pragma mark Actions
- (void)reloadData
{
    while ([[self subviews] count] > 0)
    {
		[[[self subviews] lastObject] removeFromSuperviewWithoutNeedingDisplay];
    }
	    
    [super reloadData];
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self name:NSWindowDidResignKeyNotification object:nil];
	[nc addObserver:self
		   selector:@selector(windowDidChangeKeyNotification:)
			   name:NSWindowDidResignKeyNotification
			 object:newWindow];
	
	[nc removeObserver:self name:NSWindowDidBecomeKeyNotification object:nil];
	[nc addObserver:self
		   selector:@selector(windowDidChangeKeyNotification:)
			   name:NSWindowDidBecomeKeyNotification
			 object:newWindow];
}

- (id)groupForIdentifier:(NSString *)identifier
{
	int i;
	for(i = 0; i < [self numberOfRows]; i++)
		if([self levelForRow:i] == 0)
			if([[[self itemAtRow:i] value] isEqualToString:identifier])
				return [self itemAtRow:i];
	return nil;
}


#pragma mark Notifications
- (void)queryNote:(NSNotification *)note
{	
	if ([[note name] isEqualToString:NSMetadataQueryGatheringProgressNotification] ||
		[[note name] isEqualToString:NSMetadataQueryDidUpdateNotification] ||
		[[note name] isEqualToString:NSMetadataQueryDidFinishGatheringNotification])
	{
		[self reloadData];
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSArray *collapsedGroups = [[defaults objectForKey:@"Results"] objectForKey:@"CollapsedGroups"];
		
		int i;
		for(i = 0; i < [self numberOfRows]; i++)
			if([self levelForRow:i] == 0)
				if(![collapsedGroups containsObject:[[self itemAtRow:i] value]])
					[self expandItem:[self itemAtRow:i]];
	}
}

- (void)windowDidChangeKeyNotification:(NSNotification *)notification
{
	// Group rows need to change their background color
	[self setNeedsDisplay];
}


#pragma mark Double-click Stuff
- (int)mouseRowForEvent:(NSEvent *)theEvent
{
    NSPoint mouseLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    return [self rowAtPoint:mouseLoc];
}

- (void)selectOnlyRowIndexes:(NSIndexSet *)rowIndexes
{
    [super selectRowIndexes:rowIndexes byExtendingSelection:NO];
}

- (void)selectRowIndexes:(NSIndexSet *)rowIndexes byExtendingSelection:(BOOL)flag
{
    NSEvent *theEvent     = [NSApp currentEvent];
    int      mouseRow     = [self mouseRowForEvent:theEvent];
    BOOL     modifierDown = ([theEvent modifierFlags] & PAModifierKeyMask) != 0;
    
    if ( [[self selectedRowIndexes] containsIndex:mouseRow] && (modifierDown == NO))
    {
        // this case is handled by selectOnlyRowIndexes
    }
    else
    {
        [super selectRowIndexes:rowIndexes byExtendingSelection:flag];
    }
}

- (void)mouseDown:(NSEvent *)theEvent
{
    static float doubleClickThreshold = 0.0;
    
    if ( 0.0 == doubleClickThreshold )
    {
		// TODO: CHANGE
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        doubleClickThreshold = [defaults floatForKey:@"com.apple.mouse.doubleClickThreshold"];
        
        // if we couldn't find the value in the user defaults, take a conservative estimate
        if ( 0.0 == doubleClickThreshold ) doubleClickThreshold = 0.5;
    }

    BOOL    modifierDown    = ([theEvent modifierFlags] & PAModifierKeyMask) != 0;
    BOOL    doubleClick     = ([theEvent clickCount] == 2);
    
    int mouseRow = [self mouseRowForEvent:theEvent];
    
    if ([[self selectedRowIndexes] containsIndex:mouseRow] && (modifierDown == NO) && (doubleClick == NO))
    {
        // wait to see if there is a double-click: if not, select the row as usual
        [self performSelector:@selector(selectOnlyRowIndexes:)
		           withObject:[NSIndexSet indexSetWithIndex:mouseRow]
				   afterDelay:doubleClickThreshold];
        
        // we still need to pass the event to super, to handle things like dragging, but 
        // we have disabled row deselection by overriding selectRowIndexes:byExtendingSelection:
        [super mouseDown:theEvent]; 
    }
    else if (doubleClick == YES)
    {		
        // cancel the row-selection action
        [NSObject cancelPreviousPerformRequestsWithTarget:self
											     selector:@selector(selectOnlyRowIndexes:)
												   object:[NSIndexSet indexSetWithIndex:mouseRow]];

        // perform double action
		if([[[self itemAtRow:mouseRow] class] isNotEqualTo:[NSMetadataQueryResultGroup class]])
			[[self target] performSelector:[self doubleAction]];
    }
    else
    {
        [super mouseDown:theEvent];
    }
}

- (void)dragImage:(NSImage *)anImage at:(NSPoint)imageLoc offset:(NSSize)mouseOffset event:(NSEvent *)theEvent pasteboard:(NSPasteboard *)pboard source:(id)sourceObject slideBack:(BOOL)slideBack
{
    // we are starting to drag a row(s), so cancel any pending call to change the row selection
    int     mouseRow = [self mouseRowForEvent:theEvent];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(selectOnlyRowIndexes:) object:[NSIndexSet indexSetWithIndex:mouseRow]];
    
    [super dragImage:anImage at:imageLoc offset:mouseOffset event:theEvent pasteboard:pboard source:sourceObject slideBack:slideBack];
}


#pragma mark Accessors
- (NSMetadataQuery *)query
{
	return query;
}

- (void)setQuery:(NSMetadataQuery *)aQuery
{
	query = aQuery;
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(queryNote:) name:nil object:query];
	[[self delegate] setQuery:query];
}

@end
