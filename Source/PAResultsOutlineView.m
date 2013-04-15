// Copyright (c) 2006-2012 nudge:nudge (Johannes Hoffart & Daniel BŠr). All rights reserved.
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "PAResultsOutlineView.h"


@interface NSOutlineView (PrivateAPI)

- (id)_highlightColorForCell:(NSCell *)cell;

@end


@interface PAResultsOutlineView (PrivateAPI)

- (BOOL)acceptsPreviewPanelControl:(id)panel;
- (void)beginPreviewPanelControl:(id)panel;
- (void)endPreviewPanelControl:(id)panel;

- (void)updateQuickLookUsing105;
- (BOOL)isUsingOldQuickLook;

- (int)numberOfPreviewItemsInPreviewPanel:(id)sender;
- (id)previewPanel:(id)panel previewItemAtIndex:(int)idx;

- (NSInteger)mouseRowForEvent:(NSEvent *)theEvent;
- (void)selectOnlyRowIndexes:(NSIndexSet *)rowIndexes;
- (void)selectRowIndexes:(NSIndexSet *)rowIndexes byExtendingSelection:(BOOL)flag;

- (void)beginEditing;

@end


static NSUInteger PAModifierKeyMask = NSShiftKeyMask | NSAlternateKeyMask | NSCommandKeyMask | NSControlKeyMask;

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

-(void)_drawDropHighlightOnRow:(NSInteger)rowIndex
{
	NSSize offset = NSMakeSize(3.0, 3.0);

	[self lockFocus];
	
	NSRect drawRect = [self visibleRect];
	
	drawRect.size.width -= offset.width;
	drawRect.origin.x += offset.width / 2.0;

	drawRect.size.height -= offset.height;
	drawRect.origin.y += offset.height / 2.0;

	[[NSColor colorWithDeviceRed:(185.0/255.0) green:(215.0/255.0) blue:(255.0/255.0) alpha:1.0] set];
	CGFloat lineWidth = [NSBezierPath defaultLineWidth];
	[NSBezierPath setDefaultLineWidth:3.0];
	NSBezierPath *path = [NSBezierPath bezierPathWithRoundRectInRect:drawRect radius:4.0];
	[path stroke];
	[NSBezierPath setDefaultLineWidth:lineWidth];

	[self unlockFocus];
}


#pragma mark Actions
- (NSRect)frameOfCellAtColumn:(NSInteger)column row:(NSInteger)row
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
	for(NSInteger i = 0; i < [self numberOfRows]; i++)
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
	// Just clear the selection if there are no results.
	if ([self numberOfRows] == 0)
	{
		[self setSelectedItems:[NSArray array]];
	}
	else
	{	
		// Otherwise proceed. 
		for(NSUInteger row = 0; row < [self numberOfRows]; row++)
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
			for(NSInteger i = 0; i < [self numberOfRows]; i++)
			{
				id thisItem = [self itemAtRow:i];
				
				// If this is our item, select it.
				// If it's an array, check if it contains our item.
				if ([thisItem isEqualTo:item] ||
					([thisItem isKindOfClass:[NSArray class]] && [thisItem containsObject:item]))
				{					
					NSInteger row = [self rowForItem:thisItem];
					
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

- (NSUInteger)numberOfSelectedItems
{
	return [selectedItems count];
}

#pragma mark Quick Look
- (void)toggleQuickLook
{
	if ([self quickLookIsOpen])
	{
		[self closeQuickLook];
	} else
	{
		[self openQuickLook];
	}
}

- (void)openQuickLook
{
	// Quick Look API is different on Leopard and Snow Leopard
	// 10.5: QL expects one to set its items by hand each time they change
	// 10.6: QL queries a data source for its items
	
	if ([self isUsingOldQuickLook])
	{
		[self updateQuickLook];
		[[QLPreviewPanel sharedPreviewPanel] makeKeyAndOrderFrontWithEffect:1];
	} else
	{			
		[[QLPreviewPanel sharedPreviewPanel] makeKeyAndOrderFront:self];
	}
	
	// Return focus to self
	[[self window] makeKeyWindow];
}

- (void)closeQuickLook
{
	if ([self quickLookIsOpen])
		[[QLPreviewPanel sharedPreviewPanel] close];
}

- (BOOL)quickLookIsOpen
{
	if ([self isUsingOldQuickLook])
	{
		return [[QLPreviewPanel sharedPreviewPanel] isOpen];
	} else {
		return ([QLPreviewPanel sharedPreviewPanelExists] && [[QLPreviewPanel sharedPreviewPanel] isVisible]);
	}
}

- (void)selectNextPreviewItemInQuickLook
{
	if ([self isUsingOldQuickLook])
	{
		// TODO Don't know what to do for 10.5
	}
	else
	{
		int idx = [[QLPreviewPanel sharedPreviewPanel] currentPreviewItemIndex];
		idx++;
		
		if (idx > [[self selectedItems] count] - 1)
			idx = 0;
		
		[[QLPreviewPanel sharedPreviewPanel] setCurrentPreviewItemIndex:idx];
	}
}

- (void)selectPreviousPreviewItemInQuickLook
{
	if ([self isUsingOldQuickLook])
	{
		// TODO Don't know what to do for 10.5
	}
	else
	{
		int idx = [[QLPreviewPanel sharedPreviewPanel] currentPreviewItemIndex];
		idx--;
		
		if (idx < 0)
			idx = [[self selectedItems] count] - 1;
		
		[[QLPreviewPanel sharedPreviewPanel] setCurrentPreviewItemIndex:idx];
	}
}

- (void)updateQuickLook
{
	if ([self isUsingOldQuickLook])
	{
		[self updateQuickLookUsing105];
	} else {
		[[QLPreviewPanel sharedPreviewPanel] reloadData];
	}
}

- (BOOL)isUsingOldQuickLook
{
	NSUInteger major = 0;
	NSUInteger minor = 0;
	NSUInteger bugFix = 0;
	
	[NSApp getSystemVersionMajor:&major
						   minor:&minor
						  bugFix:&bugFix];
	
	return (minor == 5);
}

#pragma mark Quick Look Delegate
- (BOOL)acceptsPreviewPanelControl:(id)panel
{
    return YES;
}

- (void)beginPreviewPanelControl:(id)panel
{
    [panel setDelegate:self];
    [panel setDataSource:self];
}

- (void)endPreviewPanelControl:(id)panel
{
	// Nothing yet
}

#pragma mark Quick Look Compatiblity Methods (10.5)
- (void)updateQuickLookUsing105
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

#pragma mark Quick Look Data Source (10.6)
- (int)numberOfPreviewItemsInPreviewPanel:(id)sender
{
	return [[self selectedItems] count];
}

- (id)previewPanel:(id)panel previewItemAtIndex:(int)idx
{
	return [NSURL fileURLWithPath:[[[self selectedItems] objectAtIndex:idx] path]];
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
			[self performSelector:@selector(updateQuickLook)
					   withObject:nil
					   afterDelay:0.1];
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

- (NSMenu *)menuForEvent:(NSEvent *)event
{
	NSInteger row = [self mouseRowForEvent:event];
	
	if (row >= 0 && [[self target] outlineView:self shouldSelectItem:[self itemAtRow:row]])
	{
		// Make sure self has the first responder
		[[self window] makeFirstResponder:self];
		
		// Select the proper row
		if (![[self selectedRowIndexes] containsIndex:row])
			[self selectRow:row byExtendingSelection:NO];
		
		// Copy over the Open With menu from main menu
		[openWithMenuItem setSubmenu:[[[[NSApp delegate] openWithMenuItem] submenu] copy]];
		
		return [self menu];
	}
	
	return nil;
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
		if (key >= 48 && key <= 122)
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
			[self toggleQuickLook];			
		}
		
		// Close Quick Look on ESC
		if (key == 27)
		{
			[self closeQuickLook];
		}
		
		// Move selection in QL if arrow right or left is pressed
		if ([self quickLookIsOpen] && key == NSRightArrowFunctionKey)
		{
			[self selectNextPreviewItemInQuickLook];
		}
		if ([self quickLookIsOpen] && key == NSLeftArrowFunctionKey)
		{
			[self selectPreviousPreviewItemInQuickLook];
		}
	}
	
	[super keyDown:theEvent];
}


#pragma mark Mouse Event Stuff
- (NSInteger)mouseRowForEvent:(NSEvent *)theEvent
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
    NSInteger      mouseRow     = [self mouseRowForEvent:theEvent];
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

    static CGFloat doubleClickThreshold = 0.0;
    
    if ( 0.0 == doubleClickThreshold )
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        doubleClickThreshold = [defaults floatForKey:@"com.apple.mouse.doubleClickThreshold"];
        
        // if we couldn't find the value in the user defaults, take a conservative estimate
        if ( 0.0 == doubleClickThreshold ) doubleClickThreshold = 0.8;
    }

    BOOL    modifierDown    = ([theEvent modifierFlags] & PAModifierKeyMask) != 0;
    BOOL    doubleClick     = ([theEvent clickCount] == 2);
    
    NSInteger mouseRow = [self mouseRowForEvent:theEvent];
    
    if ((modifierDown == NO) && (doubleClick == NO))
    {
		// cancel any previous editing action
		[NSObject cancelPreviousPerformRequestsWithTarget:self
												 selector:@selector(beginEditing)
												   object:nil];
	
		// Do only something if this row is not being edited and the user wants to
		// cancel the editing by clicking again on the item
		if (![self isEditingRow:mouseRow] && (mouseRow != -1))
		{
			NSInteger count = [[self selectedRowIndexes] count];
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
    
	NSInteger     mouseRow = [self mouseRowForEvent:theEvent];
    
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

- (NSUInteger)lastUpDownArrowFunctionKey;
{
	return lastUpDownArrowFunctionKey;
}

- (void)setLastUpDownArrowFunctionKey:(NSUInteger)key
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

- (BOOL)isEditingRow:(NSInteger)row
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
	[newUserInfo setObject:[NSNumber numberWithInteger:NSIllegalTextMovement] forKey:@"NSTextMovement"];

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

	NSInteger textMovement = [[[notification userInfo] valueForKey:@"NSTextMovement"] integerValue];

	if(textMovement == NSReturnTextMovement)
	{
		NSMutableDictionary *newUserInfo;
		newUserInfo = [[NSMutableDictionary alloc] initWithDictionary:[notification userInfo]];
		[newUserInfo setObject:[NSNumber numberWithInteger:NSIllegalTextMovement] forKey:@"NSTextMovement"];

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
