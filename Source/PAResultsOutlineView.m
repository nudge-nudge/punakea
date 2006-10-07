#import "PAResultsOutlineView.h"


static unsigned int PAModifierKeyMask = NSShiftKeyMask | NSAlternateKeyMask | NSCommandKeyMask | NSControlKeyMask;

@implementation PAResultsOutlineView

#pragma mark Init + Dealloc
- (void)awakeFromNib
{
	[self setIndentationPerLevel:16.0];
	[self setIntercellSpacing:NSMakeSize(0,1)];
	//[[self delegate] setOutlineView:self];  <- this is done via outlet in IB!
	
	// Auto-size first column
	NSRect bounds = [self bounds];
	[[[self tableColumns] objectAtIndex:0] setWidth:bounds.size.width];	
	
	// TODO: Double-click
	[self setTarget:[self delegate]];
	[self setDoubleAction:@selector(doubleAction:)];
	
	// Get notification frameDidChange
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self
	       selector:@selector(frameDidChange:)
		       name:(id)NSViewFrameDidChangeNotification
			 object:self];
	
	// Misc
	[self setDisplayMode:PAListMode];
	[self setSelectedQueryItems:[[NSMutableArray alloc] init]];
}

- (void)dealloc
{
	if(selectedQueryItems) [selectedQueryItems release];
	[super dealloc];
}


#pragma mark Drawing
- (id)_highlightColorForCell:(NSCell *)cell
{
	if([[cell class] isEqualTo:[PAResultsMultiItemCell class]])
		return [NSColor whiteColor];
				
	return [super _highlightColorForCell:cell];
}

- (void)highlightSelectionInClipRect:(NSRect)clipRect
{
	id selectedItem = [self itemAtRow:[self selectedRow]];
	
	// Clear row highlight color:
	// a) for Arrays, b) if the selected row is currently being edited
	if([selectedItem isKindOfClass:[NSArray class]] ||
	   [self editedRow] == [self selectedRow])
	{	
		[[NSColor whiteColor] set];
		NSRectFill([self rectOfRow:[self selectedRow]]);
		return;
	}
	
	/*if([[selectedItem class] isEqualTo:[NSMetadataItem class]])
	{
		if([[self window] isKeyWindow])
			[[NSColor alternateSelectedControlColor] set];
		else
			[[NSColor grayColor] set];
		
		NSRectFill([self rectOfRow:[self selectedRow]]);
		return;
	}*/
	
	[super highlightSelectionInClipRect:clipRect];
}

-(void)_drawDropHighlightOnRow:(int)rowIndex
{
	NSSize offset = NSMakeSize(3.0, 3.0);

	[self lockFocus];
	
	NSRect drawRect = [self visibleRect];
	
	drawRect.size.width -= offset.width;
	drawRect.origin.x += offset.width / 2.0;

	drawRect.size.height -= offset.height;
	drawRect.origin.y += offset.height / 2.0;

	[[NSColor colorWithDeviceRed:(185.0/255.0) green:(215.0/255.0) blue:(255.0/255.0) alpha:1.0] set];
	float lineWidth = [NSBezierPath defaultLineWidth];
	[NSBezierPath setDefaultLineWidth:3.0];
	NSBezierPath *path = [NSBezierPath bezierPathWithRoundRectInRect:drawRect radius:4.0];
	[path stroke];
	[NSBezierPath setDefaultLineWidth:lineWidth];

	[self unlockFocus];
}


#pragma mark Actions
- (NSRect)frameOfCellAtColumn:(int)column row:(int)row
{
	NSRect rect = [super frameOfCellAtColumn:column row:row];

	// Skip indentation for level 0 and shift other levels one up
	rect.origin.x -= [self indentationPerLevel];
	rect.size.width += [self indentationPerLevel];
	
	return rect;
}

/*- (BOOL)becomeFirstResponder
{
	// Make sure, at least one item is selected
	unsigned count = [[self selectedRowIndexes] count];
	if(count <= 0)
	{
		[self deselectAll:self];
		
		for(unsigned i = 0; i < [self numberOfRows]; i++)
		{
			if([[self itemAtRow:i] isKindOfClass:[PAQueryItem class]] ||
			   [[self itemAtRow:i] isKindOfClass:[NSArray class]])
			{
				[self selectRow:i byExtendingSelection:NO];
				break;
			}				
		}
	}
	
	return YES;
}*/

- (void)reloadData
{
    while ([[self subviews] count] > 0)
    {
		[[[self subviews] lastObject] removeFromSuperviewWithoutNeedingDisplay];
    }
	[self setResponder:nil];
    
	[super reloadData];
	
	// Restore group's state from user defaults
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSArray *collapsedGroups = [[defaults objectForKey:@"Results"] objectForKey:@"CollapsedGroups"];	
	for(int i = 0; i < [self numberOfRows]; i++)
	{
		id item = [self itemAtRow:i];
		if([item isKindOfClass:[PAQueryBundle class]])
		{
			if(![collapsedGroups containsObject:[item value]])
				[self expandItem:item];
		}
	}
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

- (void)setFrameSize:(NSSize)newSize 
{
	// Todo: Smooth resizing of column
	[super setFrameSize:newSize];
}

- (void)saveSelection
{	
	for(unsigned row = 0; row < [self numberOfRows]; row++)
	{
		id item = [self itemAtRow:row];
		
		if([[self selectedRowIndexes] containsIndex:row])
			[selectedQueryItems addObject:item];
		else
			[selectedQueryItems removeObject:item];
	}
}

- (void)restoreSelection
{
	[self deselectAll:self];		
	NSEnumerator *itemsEnumerator = [selectedQueryItems objectEnumerator];
	PAQueryItem *item;
	while(item = [itemsEnumerator nextObject])
	{	
		for(int i = 0; i < [self numberOfRows]; i++)
		{
			id thisItem = [self itemAtRow:i];
			
			// If this is our item, select it
			if([thisItem isEqualTo:item])
			{
				int row = [self rowForItem:thisItem];
				[self selectRow:row byExtendingSelection:YES];
				break;
			}
			
			// If this is an array, check if it contains our item
			if([thisItem isKindOfClass:[NSArray class]])
			{
				NSEnumerator *arrayEnumerator = [thisItem objectEnumerator];
				PAQueryItem *arrayItem;
				while(arrayItem = [arrayEnumerator nextObject])
				{
					if([item isEqualTo:arrayItem])
					{
						int row = [self rowForItem:thisItem];
						[self selectRow:row byExtendingSelection:YES];
						break;
					}
				}
			}
		}
	}
}


#pragma mark Notifications
- (void)queryNote:(NSNotification *)note
{	
	if([[note name] isEqualToString:PAQueryDidStartGatheringNotification])
	{
		// Reset selectedQueryItems
		if(selectedQueryItems) [selectedQueryItems release];
		selectedQueryItems = [[NSMutableArray alloc] init];
	}

	if([[note name] isEqualToString:PAQueryDidStartGatheringNotification] ||
	   [[note name] isEqualToString:PAQueryDidFinishGatheringNotification] ||
	   [[note name] isEqualToString:PAQueryDidResetNotification])
	{
		[self reloadData];
	}
	
	if([[note name] isEqualToString:PAQueryDidUpdateNotification])
	{
		[self saveSelection];
		[self reloadData];
		[self restoreSelection];
	}
}

- (void)windowDidChangeKeyNotification:(NSNotification *)notification
{
	// Group rows need to change their background color
	[self setNeedsDisplay];
}

- (void)frameDidChange:(NSNotification *)note
{
	/* As NSTableView caches row heights, we need to notify self to use the uncached
	 * new values after the frame did change
	 */
		
	//NSRange range = [self rowsInRect:[self frame]];	
	NSRange range = NSMakeRange(0,[self numberOfRows]);
	[self noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndexesInRange:range]];
	
	// TEMP - seems to work quite well, with some flickering...
	//[[self delegate] hideAllSubviews];
	[self setNeedsDisplay:YES];
}


#pragma mark Events
/**
	Custom keyDown event allows opening files with CMD + ARROW-DOWN
*/
- (void)keyDown:(NSEvent *)theEvent
{
	if([theEvent type] == NSKeyDown)
	{	
		 unichar key = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
			
		// Forward request to responder
		if([self responder])
		{
			return [[self responder] keyDown:theEvent];
		}
			
		// Store arrow key up/down value for use in multi items
		lastUpDownArrowFunctionKey = 0;
		if(key == NSDownArrowFunctionKey)
			lastUpDownArrowFunctionKey = NSDownArrowFunctionKey;
		if(key == NSUpArrowFunctionKey)
			lastUpDownArrowFunctionKey = NSUpArrowFunctionKey;	
			
		// Respond to Command + Arrow-Down	
		if(key == NSDownArrowFunctionKey &&
		   ([theEvent modifierFlags] & NSCommandKeyMask) != 0)
		{
			[[self target] performSelector:[self doubleAction]];
			return;
		}
		
		// Begin editing on Return or Enter
		if(key == NSEnterCharacter || key == '\r')
		{
			[self beginEditing];
			return;
		}
	}
	
	[super keyDown:theEvent];
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
	// Clear stored key down for multi items
	lastUpDownArrowFunctionKey = 0;	

    static float doubleClickThreshold = 0.0;
    
    if ( 0.0 == doubleClickThreshold )
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        doubleClickThreshold = [defaults floatForKey:@"com.apple.mouse.doubleClickThreshold"];
        
        // if we couldn't find the value in the user defaults, take a conservative estimate
        if ( 0.0 == doubleClickThreshold ) doubleClickThreshold = 0.8;
    }

    BOOL    modifierDown    = ([theEvent modifierFlags] & PAModifierKeyMask) != 0;
    BOOL    doubleClick     = ([theEvent clickCount] == 2);
    
    int mouseRow = [self mouseRowForEvent:theEvent];
    
    if ((modifierDown == NO) && (doubleClick == NO))
    {
		// cancel any previous editing action
		[NSObject cancelPreviousPerformRequestsWithTarget:self
												 selector:@selector(beginEditing)
												   object:nil];
	
		int count = [[self selectedRowIndexes] count];
		if([self selectedRow] == mouseRow && count <= 1)
		{
			// perform editing like finder
			[self performSelector:@selector(beginEditing)
			           withObject:nil
					   afterDelay:doubleClickThreshold];
		}
		else
		{ 	
			if([[self selectedRowIndexes] containsIndex:mouseRow])
			{
				// wait to see if there is a double-click: if not, select the row as usual
				[self performSelector:@selector(selectOnlyRowIndexes:)
						   withObject:[NSIndexSet indexSetWithIndex:mouseRow]
						   afterDelay:doubleClickThreshold];
			}
			else
			{
				[super mouseDown:theEvent];
			}
			
			// we still need to pass the event to super, to handle things like dragging, but 
			// we have disabled row deselection by overriding selectRowIndexes:byExtendingSelection:
			//[super mouseDown:theEvent]; 
		}
    }
    else if(doubleClick)
    {		
		// cancel editing action
		[NSObject cancelPreviousPerformRequestsWithTarget:self
										         selector:@selector(beginEditing)
										           object:nil];
	
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
- (PAQuery *)query
{
	return query;
}

- (void)setQuery:(PAQuery *)aQuery
{
	query = aQuery;
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(queryNote:) name:nil object:query];
}

- (unsigned int)lastUpDownArrowFunctionKey;
{
	return lastUpDownArrowFunctionKey;
}

- (void)setLastUpDownArrowFunctionKey:(unsigned int)key
{
	lastUpDownArrowFunctionKey = key;
}

- (NSResponder *)responder
{
	return responder;
}

- (void)setResponder:(NSResponder *)aResponder
{
	responder = aResponder;
}

- (PAResultsDisplayMode)displayMode
{
	return displayMode;
}

- (void)setDisplayMode:(PAResultsDisplayMode)mode
{
	displayMode = mode;
}

- (void)setSelectedQueryItems:(NSMutableArray *)theItems
{
	if(selectedQueryItems) [selectedQueryItems release];
	selectedQueryItems = [theItems retain];
}

- (NSMutableArray *)selectedQueryItems
{
	return selectedQueryItems;
}

- (void)addSelectedQueryItem:(PAQueryItem *)anItem
{
	[selectedQueryItems addObject:anItem];
}

- (void)removeSelectedQueryItem:(PAQueryItem *)anItem
{
	if([selectedQueryItems containsObject:anItem])
		[selectedQueryItems removeObject:anItem];
}


#pragma mark Editing
- (void)beginEditing
{
	[self editColumn:0 row:[self selectedRow] withEvent:nil select:YES];
}

- (void)cancelOperation:(id)sender
{	
	NSText *textView = [[self window] fieldEditor:NO forObject:self];
	[textView setString:[[self itemAtRow:[self selectedRow]] valueForAttribute:(id)kMDItemDisplayName]];
	[textView setTextColor:[NSColor textColor]];

	NSMutableDictionary *newUserInfo;
	newUserInfo = [[NSMutableDictionary alloc] init];
	[newUserInfo setObject:[NSNumber numberWithInt:NSIllegalTextMovement] forKey:@"NSTextMovement"];

	NSNotification *notification;
	notification = [NSNotification notificationWithName:NSTextDidEndEditingNotification
												 object:textView
											   userInfo:newUserInfo];
		
	[self textDidEndEditing:notification];
	
	[newUserInfo release];
	
	[[self window] makeFirstResponder:self];
}

- (void)textDidChange:(NSNotification *)notification
{
	[super textDidChange:notification];
	
	// Set text color to red if the new destination already exists
	PAQueryItem *item = [self itemAtRow:[self selectedRow]];
	PAFile *file = [PAFile fileWithPath:[item valueForAttribute:(id)kMDItemPath]];
	
	NSText *textView = [notification object];
	
	NSString *newDestination = [[file directory] stringByAppendingPathComponent:[textView string]];
	
	if([[NSFileManager defaultManager] fileExistsAtPath:newDestination] &&
	   [newDestination compare:[file path] options:NSCaseInsensitiveSearch] != NSOrderedSame)
	{
		[textView setTextColor:[NSColor redColor]];
	} else {
		[textView setTextColor:[NSColor textColor]];
	}
}

- (void)textDidEndEditing:(NSNotification *)notification
{
	NSText *textView = [notification object];

	// Force editing not to end if text color is red
	if([[textView textColor] isEqualTo:[NSColor redColor]])
	{
		[[self window] makeFirstResponder:textView];
		return;
	}

	// Force editing to end after pressing the Return key
	// See http://developer.apple.com/documentation/Cocoa/Conceptual/TextEditing/Tasks/BatchEditing.html

	int textMovement = [[[notification userInfo] valueForKey:@"NSTextMovement"] intValue];

	if(textMovement == NSReturnTextMovement)
	{
		NSMutableDictionary *newUserInfo;
		newUserInfo = [[NSMutableDictionary alloc] initWithDictionary:[notification userInfo]];
		[newUserInfo setObject:[NSNumber numberWithInt:NSIllegalTextMovement] forKey:@"NSTextMovement"];

		notification = [NSNotification notificationWithName:[notification name]
													 object:[notification object]
												   userInfo:newUserInfo];
		
		[super textDidEndEditing:notification];

		[newUserInfo release];

		[[self window] makeFirstResponder:self];
	}
	else
	{
		[super textDidEndEditing:notification];
    }
}

/**
needed for supporting dragging to trash
 */
- (void)draggedImage:(NSImage *)anImage endedAt:(NSPoint)aPoint operation:(NSDragOperation)operation
{
	if (operation == NSDragOperationDelete)
		[[self delegate] deleteDraggedItems];
}
		
@end
