#import "PAResultsOutlineView.h"


static unsigned int PAModifierKeyMask = NSShiftKeyMask | NSAlternateKeyMask | NSCommandKeyMask | NSControlKeyMask;


@interface NSOutlineView (PrivateAPI)

- (id)_highlightColorForCell:(NSCell *)cell;

@end


@interface PAResultsOutlineView (PrivateAPI)

- (int)mouseRowForEvent:(NSEvent *)theEvent;
- (void)selectOnlyRowIndexes:(NSIndexSet *)rowIndexes;
- (void)selectRowIndexes:(NSIndexSet *)rowIndexes byExtendingSelection:(BOOL)flag;

- (void)beginEditing;

@end


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
	[self setSelectedItems:[NSMutableArray array]];
	[self setSelectedItemsOfMultiItem:[NSMutableArray array]];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	if(selectedItems) [selectedItems release];
	if(selectedItemsOfMultiItem) [selectedItemsOfMultiItem release];
	
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
			if([[self itemAtRow:i] isKindOfClass:[NNQueryItem class]] ||
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
	
	// Save selected items - outlineview only stores indexes of selected rows. thus selection is
	// incorrect when adding an item above selection. we'll do this by hand as workaround
	[self setSelectedItems:[NSMutableArray array]];
	
	NSIndexSet *selectedRowIndexes = [self selectedRowIndexes];
	int row = [selectedRowIndexes firstIndex];
	
	while(row != NSNotFound)
	{
		[[self selectedItems] addObject:[self itemAtRow:row]];
		
		row = [selectedRowIndexes indexGreaterThanIndex:row];
	}
    
	// Forward reload request to super
	[super reloadData];
	
	// Restore selection
	[self deselectAll:self];
	NSEnumerator *enumerator = [[self selectedItems] objectEnumerator];
	NNTaggableObject *item;
	while(item = [enumerator nextObject])
	{
		row = [self rowForItem:item];
		[self selectRow:row byExtendingSelection:YES];
	}	
	
	// Restore group's state from user defaults
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSArray *collapsedGroups = [[defaults objectForKey:@"Results"] objectForKey:@"CollapsedGroups"];	
	for(int i = 0; i < [self numberOfRows]; i++)
	{
		id item = [self itemAtRow:i];
		if([item isKindOfClass:[NNQueryBundle class]])
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
	[super setFrameSize:newSize];
}

- (void)saveSelection
{
	for(unsigned row = 0; row < [self numberOfRows]; row++)
	{
		id item = [self itemAtRow:row];
		
		if([[self selectedRowIndexes] containsIndex:row])
		{
			//if (![selectedItems containsObject:item])
			[[self selectedItems] addObject:item];
		}
		else 
		{
			[[self selectedItems] removeObject:item];
		}
	}
}

- (void)restoreSelection
{
	/*[self deselectAll:self];		
	NSEnumerator *itemsEnumerator = [[self selectedItems] objectEnumerator];
	NNTaggableObject *item;
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
				if([thisItem containsObject:item])
				{
					int row = [self rowForItem:thisItem];
					[self selectRow:row byExtendingSelection:YES];
					break;
				}
			}
		}
	}*/
}

- (NSArray *)visibleSelectedItems
{
	[self saveSelection];
	
	NSMutableArray *selItems = [NSMutableArray array];
	
	for(unsigned row = 0; row < [self numberOfRows]; row++)
	{
		id item = [self itemAtRow:row];
		
		if([[self selectedRowIndexes] containsIndex:row])
		{
			if([item isKindOfClass:[NSArray class]] && [self responder])
			{
				NSArray *responderItems = [[self responder] selectedItems];
				[selItems addObjectsFromArray:responderItems];
			}
			else
			{
				[selItems addObject:item];		
			}
		}
	}
	
	return selItems;
}

- (void)selectAll:(id)sender
{
	if([self responder])
		[responder selectAll:sender];
	else
		[super selectAll:sender];
}

#pragma mark Notifications
- (void)queryNote:(NSNotification *)note
{	
	if([[note name] isEqualToString:NNQueryDidStartGatheringNotification])
	{
		// Reset selectedItems
		[self setSelectedItems:[NSMutableArray array]];
		[self setSelectedItemsOfMultiItem:[NSMutableArray array]];
	}

	if([[note name] isEqualToString:NNQueryDidStartGatheringNotification] ||
	   [[note name] isEqualToString:NNQueryDidFinishGatheringNotification] ||
	   [[note name] isEqualToString:NNQueryDidResetNotification])
	{	
		[self reloadData];
	}
	
	if([[note name] isEqualToString:NNQueryDidUpdateNotification])
	{		
		[self saveSelection];
		NSRect visibleRect = [self visibleRect];
		
		NSDictionary *userInfo = [note userInfo];
		
		/*NSArray *userInfoAddedItems = [userInfo objectForKey:(id)kMDQueryUpdateAddedItems];
		NSEnumerator *enumerator = [userInfoAddedItems objectEnumerator];
		NNQueryItem *item;
		while(item = [enumerator nextObject]) {
			NSLog(@"added: %@",[item valueForAttribute:(id)kMDItemDisplayName]);
		}*/
		
		NSArray *userInfoRemovedItems = [userInfo objectForKey:(id)kMDQueryUpdateRemovedItems];
		NSEnumerator *enumerator = [userInfoRemovedItems objectEnumerator];
		NNTaggableObject *item;
		while(item = [enumerator nextObject])
		{
			if([[self selectedItems] containsObject:item])
				[[self selectedItems] removeObject:item];
			
			if([[self selectedItemsOfMultiItem] containsObject:item])
				[[self selectedItemsOfMultiItem] removeObject:item];
		}
		
		[self reloadData];
		
		[self scrollPoint:visibleRect.origin];
		[self restoreSelection];

		[[self window] makeFirstResponder:self];
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
	
	[self setNeedsDisplay:YES];
}


#pragma mark Events
/**
	Custom keyDown event allows opening files with CMD + ARROW-DOWN
*/
- (void)keyDown:(NSEvent *)theEvent
{
	unichar key = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];

	if([theEvent type] == NSKeyDown)
	{				
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
		if((key == NSEnterCharacter || key == '\r') &&
		  [[self selectedRowIndexes] count] == 1)
		{
			[self beginEditing];
			return;
		}
		
		// Disable forwarding of alphanumeric keys to super (otherwise typeahead find starts)
		if((key >= 48 && key <= 122) || key == 27) return;  
	}
	
	[super keyDown:theEvent];
}


#pragma mark Mouse Event Stuff
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
		else if([[self selectedRowIndexes] containsIndex:mouseRow])
		{
			// wait to see if there is a double-click: if not, select the row as usual
			[self performSelector:@selector(selectOnlyRowIndexes:)
					   withObject:[NSIndexSet indexSetWithIndex:mouseRow]
					   afterDelay:doubleClickThreshold];
		}
		
		// we still need to pass the event to super, to handle things like dragging, but 
		// we have disabled row deselection by overriding selectRowIndexes:byExtendingSelection:
		[super mouseDown:theEvent]; 
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
		if([[[self itemAtRow:mouseRow] class] isNotEqualTo:[NNQueryBundle class]])
			[[self target] performSelector:@selector(doubleAction:)];
    }
    else
    {
        [super mouseDown:theEvent];
    }
}

- (void)dragImage:(NSImage *)anImage at:(NSPoint)imageLoc offset:(NSSize)mouseOffset event:(NSEvent *)theEvent pasteboard:(NSPasteboard *)pboard source:(id)sourceObject slideBack:(BOOL)slideBack
{
    // we are starting to drag one or more rows, so cancel any pending calls from our custom mouse down
    
	int     mouseRow = [self mouseRowForEvent:theEvent];
    
	// cancel editing action
	[NSObject cancelPreviousPerformRequestsWithTarget:self
											 selector:@selector(beginEditing)
											   object:nil];
											   
	// cancel the row-selection action
	[NSObject cancelPreviousPerformRequestsWithTarget:self
											 selector:@selector(selectOnlyRowIndexes:)
											   object:[NSIndexSet indexSetWithIndex:mouseRow]];
    
    [super dragImage:anImage at:imageLoc offset:mouseOffset event:theEvent pasteboard:pboard source:sourceObject slideBack:slideBack];
}

/**
needed for supporting dragging to trash
 */
- (void)draggedImage:(NSImage *)anImage endedAt:(NSPoint)aPoint operation:(NSDragOperation)operation
{
	if (operation == NSDragOperationDelete)
		[[self delegate] deleteDraggedItems];
}


#pragma mark Accessors
- (NNQuery *)query
{
	return query;
}

- (void)setQuery:(NNQuery *)aQuery
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

- (NSMutableArray *)selectedItems
{
	//[self saveSelection];
	return selectedItems;
}

- (void)setSelectedItems:(NSMutableArray *)theItems
{
	if(selectedItems) [selectedItems release];
	selectedItems = [theItems retain];
}

- (NSMutableArray *)selectedItemsOfMultiItem
{
	return selectedItemsOfMultiItem;
}

- (void)setSelectedItemsOfMultiItem:(NSMutableArray *)theItems
{
	if(selectedItemsOfMultiItem) [selectedItemsOfMultiItem release];
	selectedItemsOfMultiItem = [theItems retain];
}


#pragma mark Editing
- (void)beginEditing
{		
	if(![[self selectedRowIndexes] count] == 1) return;

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
	// Set text color to red if the new destination already exists
	NNTaggableObject *taggableObject = [self itemAtRow:[self selectedRow]];
	
	NSText *textView = [notification object];
	NSString *newName = [textView string];
	
	if(![taggableObject validateNewName:newName])
		[textView setTextColor:[NSColor redColor]];
	else 
		[textView setTextColor:[NSColor textColor]];
	
	[self setNeedsDisplay:YES];
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


#pragma mark Live Resizing
- (BOOL) _wantsLiveResizeToUseCachedImage;
{
    return NO;
}

- (BOOL) _shouldLiveResizeUseCachedImage;
{
    return NO;
}
		
@end
