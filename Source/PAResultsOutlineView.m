#import "PAResultsOutlineView.h"


@interface NSOutlineView (PrivateAPI)

- (id)_highlightColorForCell:(NSCell *)cell;

@end


@interface PAResultsOutlineView (PrivateAPI)

- (void)triggerQuickLook;
- (void)updateQuickLookUrls;

- (int)mouseRowForEvent:(NSEvent *)theEvent;
- (void)selectOnlyRowIndexes:(NSIndexSet *)rowIndexes;
- (void)selectRowIndexes:(NSIndexSet *)rowIndexes byExtendingSelection:(BOOL)flag;

- (void)beginEditing;

@end


static unsigned int PAModifierKeyMask = NSShiftKeyMask | NSAlternateKeyMask | NSCommandKeyMask | NSControlKeyMask;

NSString *PAResultsOutlineViewSelectionDidChangeNotification = @"PAResultsOutlineViewSelectionDidChangeNotification";

#define QLPreviewPanel NSClassFromString(@"QLPreviewPanel")


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
	
	// Get notifications
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	
	[nc addObserver:self
	       selector:@selector(frameDidChange:)
		       name:(id)NSViewFrameDidChangeNotification
			 object:self];
	
	[nc addObserver:self
		   selector:@selector(selectionDidChange:)
			   name:(id)NSOutlineViewSelectionDidChangeNotification
			 object:self];
	
	// Misc
	[self setDisplayMode:PAListMode];
	[self setSelectedItems:[NSMutableArray array]];

	skipSaveSelection = NO;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	if(selectedItems) [selectedItems release];
	
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
	// Change global flag
	skipSaveSelection = YES;
	
    while ([[self subviews] count] > 0)
    {
		[[[self subviews] lastObject] removeFromSuperviewWithoutNeedingDisplay];
    }
	[self setResponder:nil];
	  
	// Forward reload request to super
	[super reloadData];
		
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
	
	// Restore selection
	[self restoreSelection];	
	
	// Change global flag
	skipSaveSelection = NO;
	
	// Now call notification handler that selection may have changed
	[self selectionDidChange:nil];
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
	// Just clear the selection if there are no tags selected.
	if ([[query tags] count] == 0)
	{
		[self setSelectedItems:[NSArray array]];
	}
	else
	{	
		// Otherwise proceed. 
		for(unsigned row = 0; row < [self numberOfRows]; row++)
		{
			id item = [self itemAtRow:row];
			
			if([[self selectedRowIndexes] containsIndex:row])
			{			
				// Add to selection
				
				if (![item isKindOfClass:[NSArray class]]) 
				{					
					[self addSelectedItem:item];
				}
			}
			else
			{
				// Remove from selection
				
				if (![item isKindOfClass:[NSArray class]])
				{
					[self removeSelectedItem:item];
				}
				else
				{
					for (NNTaggableObject *subitem in (NSArray *)item)
					{
						[self removeSelectedItem:subitem];
					}
					
					[[self responder] setSelectedItems:[NSArray array]];
				}
			}
		}
	}
}

- (void)restoreSelection
{
	skipSaveSelection = YES;	
	
	// Start with an empty selection	
	[self deselectAll:self];

	// Only do something if there are results
	if ([self numberOfRows] > 0) 
	{
		// There may be a new result set with less items, so we need to check which items are still valid
		NSMutableArray *validSelectedItems = [NSMutableArray array];
		
		for (NNTaggableObject *item in selectedItems)
		{			
			for(int i = 0; i < [self numberOfRows]; i++)
			{
				id thisItem = [self itemAtRow:i];
				
				// If this is our item, select it.
				// If it's an array, check if it contains our item.
				if ([thisItem isEqualTo:item] ||
					([thisItem isKindOfClass:[NSArray class]] && [thisItem containsObject:item]))
				{					
					int row = [self rowForItem:thisItem];
					
					[self selectRow:row byExtendingSelection:YES];
					
					[validSelectedItems addObject:item];
					
					break;
				}
			}
		}
		
		// Update selected items
		[self setSelectedItems:validSelectedItems];
	}
	
	skipSaveSelection = NO;
}

- (void)selectAll:(id)sender
{
	if([self responder])
		[responder selectAll:sender];
	else
		[super selectAll:sender];
}

- (void)addSelectedItem:(NNTaggableObject *)item
{
	if (![selectedItems containsObject:item])
		[selectedItems addObject:item];
}

- (void)removeSelectedItem:(NNTaggableObject *)item
{
	[selectedItems removeObject:item];
}

- (unsigned)numberOfSelectedItems
{
	return [selectedItems count];
}

- (void)triggerQuickLook
{
	if ([[QLPreviewPanel sharedPreviewPanel] isOpen])
	{
		[[QLPreviewPanel sharedPreviewPanel] closeWithEffect:1];
	} else {
		[self updateQuickLookUrls];		
		[[QLPreviewPanel sharedPreviewPanel] makeKeyAndOrderFrontWithEffect:1];
		[[self window] makeKeyWindow];
	}
}

- (void)updateQuickLookUrls
{
	NSMutableArray *urls = [NSMutableArray array];
	
	for (NNFile *file in [self selectedItems])
	{
		[urls addObject:[NSURL fileURLWithPath:[file path]]];
	}
	
	[[QLPreviewPanel sharedPreviewPanel] setURLs:urls
									currentIndex:0
						  preservingDisplayState:YES];
}


#pragma mark Notifications
- (void)selectionDidChange:(NSNotification *)notification
{
	// Do not send notification if OutlineView is currently reloading data.
	if(!skipSaveSelection)
	{
		[self saveSelection];
		
		NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[self selectedItems]
															 forKey:@"SelectedItems"];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:PAResultsOutlineViewSelectionDidChangeNotification 
															object:self
														  userInfo:userInfo];
		
		// Update Quick Look URLs
		if ([[QLPreviewPanel sharedPreviewPanel] isOpen])
		{
			[self updateQuickLookUrls];
		}
	}
}

- (void)queryNote:(NSNotification *)note
{	
	if ([[note name] isEqualToString:NNQueryDidStartGatheringNotification])
	{
		// Nothing yet
	}

	if ([[note name] isEqualToString:NNQueryDidUpdateNotification])
	{				
		NSRect visibleRect = [self visibleRect];
				
		[self reloadData];
		
		[self scrollPoint:visibleRect.origin];
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
- (BOOL)performKeyEquivalent:(NSEvent *)theEvent
{
	unichar key = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
	
	if([theEvent type] == NSKeyDown)
	{
		// Delete files on Command + Delete
		if(key == NSDeleteCharacter &&
		   ([theEvent modifierFlags] & NSCommandKeyMask) != 0 &&
		   [[self selectedRowIndexes] count] > 0)
		{			
			if([[self selectedRowIndexes] count] > 0)
				[[self target] deleteFilesForSelectedItems:self];
			
			return YES;
		}
	}
	
	return [super performKeyEquivalent:theEvent];
}

/**
	Custom keyDown event allows opening files with CMD + ARROW-DOWN
*/
- (void)keyDown:(NSEvent *)theEvent
{
	unichar key = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];

	if([theEvent type] == NSKeyDown)
	{			
		// Forward request to responder,
		// except: Backspace key - called NSDeleteCharacter!! - action: clear latest selected tag
		if([self responder] &&
			key != NSDeleteCharacter)
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
		if((key >= 48 && key <= 122) || key == 27)
			return;  
		
		// Handle tab character by hand, as otherwise - with Leopard - editing begins.
		if(key == NSTabCharacter)
		{
			NSView *nextValidKeyView = [self nextValidKeyView];			
			[[self window] makeFirstResponder:nextValidKeyView];			
			return;
		}
		
		// Open/close Quick Look on Space
		if (key == 32)
		{			
			[self triggerQuickLook];			
		}
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
	
		// Do only something if this row is not being edited and the user wants to
		// cancel the editing by clicking again on the item
		if (![self isEditingRow:mouseRow])
		{
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

- (NSArray *)selectedItems
{
	return [NSArray arrayWithArray:selectedItems];
}

- (void)setSelectedItems:(NSArray *)theItems
{
	if(selectedItems) [selectedItems release];
	
	selectedItems = [[NSMutableArray alloc] initWithArray:theItems];
}

- (BOOL)isEditingRow:(int)row
{
	if ([self numberOfSelectedItems] != 1)
		return NO;
	
	if ([self rowForItem:[[self selectedItems] objectAtIndex:0]] != row)
		return NO;
	
	NSText *textView = [[self window] fieldEditor:NO forObject:self];
	return [textView isFieldEditor];
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
