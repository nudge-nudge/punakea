//
//  PASourcePanel.m
//  punakea
//
//  Created by Daniel on 28.03.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PASourcePanel.h"


@implementation PASourcePanel

- (void)awakeFromNib
{
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
	if([[[self window] firstResponder] isDescendantOf:self] &&
	   [[self window] isKeyWindow]) 
	{
		imageRect.origin.x = 0.0;
	} else {
		imageRect.origin.x = 1.9;
	}
	
	[backgroundImage drawInRect:rowRect fromRect:imageRect operation:NSCompositeSourceOver fraction:1.0];
	
	//[super highlightSelectionInClipRect:clipRect];
}

-(void)_drawDropHighlightOnRow:(int)rowIndex
{
	NSSize offset = NSMakeSize(3.0, 3.0);
	
	[self lockFocus];
	
	NSRect drawRect = [self rectOfRow:rowIndex];
	
	drawRect.size.width -= offset.width;
	drawRect.origin.x += offset.width / 2.0;
	
	drawRect.size.height -= offset.height;
	drawRect.origin.y += offset.height / 2.0;
	
	NSBezierPath *path = [NSBezierPath bezierPathWithRoundRectInRect:drawRect radius:4.0];
	
	// Stroke
	[[NSColor colorWithDeviceRed:(7.0/255.0) green:(82.0/255.0) blue:(215.0/255.0) alpha:1.0] set];
	[[NSGraphicsContext currentContext] setShouldAntialias:NO];
	[path fill];
	[[NSGraphicsContext currentContext] setShouldAntialias:YES];
	
	// Fill with 172,193,226
	[[NSColor colorWithDeviceRed:(172.0/255.0) green:(193.0/255.0) blue:(226.0/255.0) alpha:1.0] set];
	path = [NSBezierPath bezierPathWithRoundRectInRect:NSInsetRect(drawRect, 2.0, 2.0) radius:4.0];
	[path fill];
	
	// Force drawing of content
	[self drawRow:rowIndex clipRect:drawRect];
	
	[self unlockFocus];
}

- (void)_drawDropHighlightBetweenUpperRow:(int)inUpper andLowerRow:(int)inLower atOffset:(float)inOffset
{	
	[self lockFocus];
	
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
	
	[self unlockFocus];
}


#pragma mark Misc
- (NSRect)frameOfCellAtColumn:(int)column row:(int)row
{
	NSRect rect = [super frameOfCellAtColumn:column row:row];
	
	// Skip half indentation for level 0 and shift other levels one half #up
	rect.origin.x -= [self indentationPerLevel] / 2;
	rect.size.width += [self indentationPerLevel] / 2;
	
	return rect;
}

- (void)reloadData
{
	[super reloadData];
	
	// Expand all items and select first selectable item
	BOOL selectableItemFound = NO;
	
	for(int row = 0; row < [self numberOfRows]; row++)
	{
		id item = [self itemAtRow:row];
		[self expandItem:item expandChildren:YES];
		
		if([self selectedRow] == 0 &&
		   !selectableItemFound &&
		   [item isKindOfClass:[PASourceItem class]] &&
		   [(PASourceItem *)item isSelectable])
		{
			[self selectRow:row byExtendingSelection:NO];
			selectableItemFound = YES;
		}
	}
}


#pragma mark Events
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
	}
	
	[super keyDown:theEvent];
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
	[textView setString:[[self itemAtRow:[self selectedRow]] displayName]];
	
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
	/*NNTaggableObject *taggableObject = [self itemAtRow:[self selectedRow]];
	
	NSText *textView = [notification object];
	NSString *newName = [textView string];
	
	if(![taggableObject validateNewName:newName])
		[textView setTextColor:[NSColor redColor]];
	else 
		[textView setTextColor:[NSColor textColor]];
	
	[self setNeedsDisplay:YES];*/
}

- (void)textDidEndEditing:(NSNotification *)notification
{
	NSText *textView = [notification object];
	
	// Force editing not to end if text color is red
	/*if([[textView textColor] isEqualTo:[NSColor redColor]])
	{
		[[self window] makeFirstResponder:textView];
		return;
	}*/
	
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

@end
