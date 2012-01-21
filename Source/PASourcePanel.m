// Copyright (c) 2006-2011 nudge:nudge (Johannes Hoffart & Daniel Bär). All rights reserved.
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

#import "PASourcePanel.h"


@interface PASourcePanel (PrivateAPI)

- (void)beginEditing;

@end


static NSUInteger PAModifierKeyMask = NSShiftKeyMask | NSAlternateKeyMask | NSCommandKeyMask | NSControlKeyMask;


@implementation PASourcePanel

- (void)awakeFromNib
{
	[self setIndentationPerLevel:8.0];
	[self setIntercellSpacing:NSZeroSize];
	
	[self registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
	[self setDraggingSourceOperationMask:NSDragOperationNone forLocal:NO];
	[self setDraggingSourceOperationMask:NSDragOperationAll forLocal:YES];
}

#pragma mark Drawing
- (id)_highlightColorForCell:(NSCell *)cell
{				
	return nil;
}

- (void)highlightSelectionInClipRect:(NSRect)clipRect
{
	NSRect rowRect = [self rectOfRow:[self selectedRow]];
	
	// Draw background
	NSImage *backgroundImage = [NSImage imageNamed:@"SourcePanelSelectionGradient"];
	
	if([self isFlipped]) [backgroundImage setFlipped:YES];
	[backgroundImage setScalesWhenResized:YES];
	
	// Using 0.1 and 1.9 instead of 1.0 as there seems to be some antialiasing :( 
	
	NSRect imageRect;
	imageRect.origin = NSZeroPoint;
	imageRect.size.width = 0.1;
	imageRect.size.height = [backgroundImage size].height;
	
	// Decide which color to use
	NSResponder *firstResponder = [[self window] firstResponder];
	
	if([[self window] isKeyWindow] && 
	   ([firstResponder isEqualTo:self] ||
		([firstResponder isEqualTo:[[self window] fieldEditor:NO forObject:self]] &&
		 [[[[self window] fieldEditor:NO forObject:self] delegate] isEqualTo:self]))
	   ) 
	{
		imageRect.origin.x = 0.0;
	} else {
		imageRect.origin.x = 1.9;
	}
	
	[backgroundImage drawInRect:rowRect fromRect:imageRect operation:NSCompositeSourceOver fraction:1.0];
	
	//[super highlightSelectionInClipRect:clipRect];
}

// WE DOT NEED THIS HACK ON LEOPARD ANY MORE

/*-(void)_drawDropHighlightOnRow:(int)rowIndex
{
	NSLog(@"on row");
	
	NSSize offset = NSMakeSize(2.0, 2.0);
	
	NSRect drawRect = [self rectOfRow:rowIndex];
	
	drawRect.size.width -= offset.width;
	drawRect.origin.x += offset.width / 2.0 - 1.0;
	
	drawRect.size.height -= offset.height;
	drawRect.origin.y += offset.height / 2.0;
	
	NSBezierPath *path = [NSBezierPath bezierPathWithRect:drawRect];
	[path setLineWidth:2.0];
	
	// Stroke	
	[[NSColor colorWithDeviceRed:(7.0/255.0) green:(82.0/255.0) blue:(215.0/255.0) alpha:1.0] set];
	[path fill];
	
	// Fill with 172,193,226
	[[NSColor colorWithDeviceRed:(172.0/255.0) green:(193.0/255.0) blue:(226.0/255.0) alpha:1.0] set];
	path = [NSBezierPath bezierPathWithRect:NSInsetRect(drawRect, 2.0, 2.0)];
	[path fill];
	
	// Force drawing of content
	[self drawRow:rowIndex clipRect:drawRect];
}

- (void)_drawDropHighlightBetweenUpperRow:(int)inUpper andLowerRow:(int)inLower onRow:(int)theRow atOffset:(float)inOffset
{	
	NSLog(@"between");
	
	// Remember lineWidth	float lineWidth = [NSBezierPath defaultLineWidth];
	float lineWidth = [NSBezierPath defaultLineWidth];
	[NSBezierPath setDefaultLineWidth:2.0];
	
	NSRect upperRowRect = [self rectOfRow:inUpper];
	
	NSRect upperFirstCellRect = [self frameOfCellAtColumn:0 row:inUpper];
	NSRect lowerFirstCellRect = [self frameOfCellAtColumn:0 row:inLower];
	
	NSRect drawRect;
	
	// Ignore inOffset, x offset depends on where we are - we use frameOfCellAtColumn to determine it
	if([self itemAtRow:inLower])
		drawRect.origin.x = lowerFirstCellRect.origin.x;
	else
		drawRect.origin.x = upperFirstCellRect.origin.x;
	
	drawRect.origin.x - 2.0;													// connect to circle
	drawRect.origin.y = upperRowRect.origin.y + upperRowRect.size.height - 1.0;	// exact mid position
	drawRect.size.height = 2.0;													// 2px line height
	drawRect.size.width = upperRowRect.size.width - drawRect.origin.x;
	
	[[NSColor colorWithDeviceRed:(7.0/255.0) green:(82.0/255.0) blue:(215.0/255.0) alpha:1.0] set];
	
	NSBezierPath *path = [NSBezierPath bezierPathWithRect:drawRect];
	[path fill];
	
	// Draw circle
	NSRect circleRect;
	circleRect.origin.x = drawRect.origin.x - 6.0;
	circleRect.origin.y = drawRect.origin.y - 2.0;
	circleRect.size.width = 6.0;
	circleRect.size.height = 6.0;
	
	path = [NSBezierPath bezierPathWithOvalInRect:circleRect];
	[path stroke];
	
	[NSBezierPath setDefaultLineWidth:lineWidth];
}*/

// Also new for Leopard, also private
/* +(id)_dropHighlightBackgroundColor {} */


#pragma mark Mouse Events
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
		if ([self editedRow] != mouseRow)
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
		if([(PASourceItem *)[self itemAtRow:mouseRow] isEditable])
			[[self delegate] performSelector:@selector(doubleAction:)];
    }
    else
    {
        [super mouseDown:theEvent];
    }
}


#pragma mark Misc
- (NSRect)frameOfCellAtColumn:(NSInteger)column row:(NSInteger)row
{
	NSRect rect = [super frameOfCellAtColumn:column row:row];
	
	// Add one more indentation per level except for level 0
	// NOTE: If we want to shift our levels up or down, make indentationPerLevel less than the value
	// that we want it to be and shift them up/down in frameOfCellAtColumn. This causes the triangle
	// not to be drawn above our cell. Clicking on the cell's content would cause it to
	// expand/collapse otherwise.
	
	NSInteger level = [self levelForRow:row];
	if(level > 0)
	{
		rect.origin.x += level * [self indentationPerLevel];
		rect.size.width -= level * [self indentationPerLevel];
	}
	
	return rect;
}

- (void)selectItemWithValue:(NSString *)value
{
	for(NSInteger row = 0; row < [self numberOfRows]; row++)
	{
		PASourceItem *item = [self itemAtRow:row];
		
		if([[item value] isEqualTo:value])
		{
			[self selectOnlyRowIndexes:[NSIndexSet indexSetWithIndex:row]];
			return;
		}
	}
}

- (void)reloadData
{
	[super reloadData];
	
	// Expand all items except ALL_ITEMS (hardcoded for now) and select first selectable item
	BOOL selectableItemFound = NO;
	
	for(NSInteger row = 0; row < [self numberOfRows]; row++)
	{
		id item = [self itemAtRow:row];
		
		if([self isExpandable:item])
		{
			if([[item value] isEqualTo:@"ALL_ITEMS"])
			{
				// Check User Defaults for state
				NSDictionary *dict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"SourcePanel"];
				NSArray *expandedItems = [dict objectForKey:@"ExpandedItems"];
				if([expandedItems containsObject:@"ALL_ITEMS"])
					[self expandItem:item expandChildren:NO];
			} else {
				// Just expand the item
				[self expandItem:item expandChildren:NO];
			}
		}
			
		if([self selectedRow] == 0 &&
		   !selectableItemFound &&
		   [(PASourceItem *)item isSelectable])
		{
			[self selectRow:row byExtendingSelection:NO];
			selectableItemFound = YES;
		}
	}
}

- (void)reloadDataAndSelectItemWithValue:(NSString *)value
{
	[self selectItemWithValue:value];
	[self reloadData];	
}

- (PASourceItem *)itemWithValue:(NSString *)value
{
	for(NSInteger row = 0; row < [self numberOfRows]; row++)
	{
		PASourceItem *item = [self itemAtRow:row];
		if([[item value] isEqualTo:value])
			return item;
	}
	return nil;
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
		   [(PASourceItem *)[self itemAtRow:[self selectedRow]] isEditable])
		{			
			[[[NSApplication sharedApplication] delegate] delete:self];
			return YES;
		}
	}
	
	return [super performKeyEquivalent:theEvent];
}

- (void)keyDown:(NSEvent *)theEvent
{
	unichar key = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
	
	if([theEvent type] == NSKeyDown)
	{			
		// Begin editing on Return or Enter
		if((key == NSEnterCharacter || key == '\r') &&
		   [[self selectedRowIndexes] count] == 1)
		{
			[self beginEditing];
			return;
		}
		
		// Handle tab character by hand, as otherwise - with Leopard - editing begins.
		if(key == NSTabCharacter)
		{
			NSView *nextValidKeyView = [self nextValidKeyView];			
			[[self window] makeFirstResponder:nextValidKeyView];			
			return;
		}
		
		// Prevent alphanumeric keys to be sent to tag cloud whenever a modifierkey is pressed
		if ([[NSCharacterSet alphanumericCharacterSet] characterIsMember:key] &&
			([theEvent modifierFlags] & PAModifierKeyMask) != 0) 
		{
			return;
		}
	}
	
	[super keyDown:theEvent];
}

/* - (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
	// Allow menu only for editable items by now
			
	NSPoint mousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	NSInteger row = [self rowAtPoint:mousePoint];		
	PASourceItem *item = (PASourceItem *)[self itemAtRow:row];
	
	if([item isEditable])
	{
		[[self window] makeFirstResponder:self];
		return [super menuForEvent:theEvent];
	} else {
		return nil;
	}
} */

- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
	if ([theEvent type] == NSRightMouseDown)
	{
		// get the current selections for the outline view. 
		NSIndexSet *selectedRowIndexes = [self selectedRowIndexes];
		
		// select the row that was clicked before showing the menu for the event
		NSPoint mousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
		int row = [self rowAtPoint:mousePoint];
		
		PASourceItem *item = (PASourceItem *)[self itemAtRow:row];
		if([item isEditable])
		{
			if ([selectedRowIndexes containsIndex:row] == NO)
				[self selectRow:row byExtendingSelection:NO];
			
			[[self window] makeFirstResponder:self];
			return [super menuForEvent:theEvent];
		}
	}
	
	return nil;
}


#pragma mark Editing
- (void)removeSelectedItem
{
	PASourceItem *sourceItem = [self itemAtRow:[self selectedRow]];
	
	if(!(sourceItem && [sourceItem isEditable]))
		return;
	
	// Retaining the item saves us from crashing ;)
	[sourceItem retain];
	
	[[sourceItem parent] removeChild:sourceItem];
	
	[self reloadDataAndSelectItemWithValue:@"ALL_ITEMS"];
	
	// Now it should be save to release the item
	[sourceItem release];
}

- (void)beginEditing
{		
	if(![[self selectedRowIndexes] count] == 1) return;
	
	[self editColumn:0 row:[self selectedRow] withEvent:nil select:YES];
	
	NSTextView *editor = (NSTextView *)[[self window] fieldEditor:YES forObject:self];

	[[editor textContainer] setContainerSize:NSMakeSize(CGFLOAT_MAX, 16.0)];
	[[editor textContainer] setWidthTracksTextView:NO];
}

- (void)cancelOperation:(id)sender
{	
	NSTextView *editor = (NSTextView *)[[self window] fieldEditor:NO forObject:self];
	[editor setString:[[self itemAtRow:[self selectedRow]] displayName]];
	
	NSMutableDictionary *newUserInfo = [[NSMutableDictionary alloc] init];
	[newUserInfo setObject:[NSNumber numberWithInteger:NSIllegalTextMovement] forKey:@"NSTextMovement"];
	
	NSNotification *notification;
	notification = [NSNotification notificationWithName:NSTextDidEndEditingNotification
												 object:editor
											   userInfo:newUserInfo];
	
	[self textDidEndEditing:notification];
	
	[newUserInfo release];
	
	[[self window] makeFirstResponder:self];
}

- (void)textDidChange:(NSNotification *)notification
{		
	NSTextView *editor = [notification object];
	
	PASourceItem *editedItem = [self itemAtRow:[self editedRow]];
	
	PASourceItem *favorites = [self itemWithValue:@"FAVORITES"];
	
	// Check on duplicates - compare display names only
	BOOL hasDuplicate = NO;
	
	NSEnumerator *e = [[favorites children] objectEnumerator];
	PASourceItem *item;
	while(item = [e nextObject])
	{
		if(item != editedItem &&
		   [[editor string] isEqualTo:[item displayName]])
		{
			hasDuplicate = YES;
			break;
		}
	}
	
	if(hasDuplicate || [[editor string] length] == 0)
		[editor setTextColor:[NSColor redColor]];
	else
		[editor setTextColor:[NSColor textColor]];
	
	[editor setNeedsDisplay:YES];
	[self setNeedsDisplay:YES];
}

- (void)textDidEndEditing:(NSNotification *)notification
{	
	NSTextView *editor = [notification object];
	
	// Force editing not to end if text color is red
	if([[editor textColor] isEqualTo:[NSColor redColor]])
	{
		[editor setTextColor:[NSColor textColor]];
		[self cancelOperation:editor];
		return;
	}
	
	[[editor enclosingScrollView] removeFromSuperview];
	
	[self setNeedsDisplay:YES];
	
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
