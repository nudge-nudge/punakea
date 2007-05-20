//
//  PASourceItemCell.m
//  punakea
//
//  Created by Daniel on 29.03.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PASourceItemCell.h"


@implementation PASourceItemCell

#pragma mark Init + Dealloc
- (id)initTextCell:(NSString *)aText
{
	self = [super initTextCell:aText];
	if (self)
	{
		// nothing yet
	}	
	return self;
}

- (void)dealloc
{
	[super dealloc];
}


#pragma mark Drawing
- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{		 
	// Draw a triangle for ALL_ITEMS - hardcoded value, as we'll update this workaround later on	
	if([[item value] isEqualTo:@"ALL_ITEMS"])
	{	
		// Check if triangle already exists in controlView
		// References are not kept because cells are autoreleased
		NSEnumerator *enumerator = [[controlView subviews] objectEnumerator];
		id anObject;
		PAImageButton *triangle = nil;
		
		while(anObject = [enumerator nextObject])
		{
			if([anObject isKindOfClass:[PAImageButton class]])
			{
				NSDictionary *tag = [(PAImageButton *)anObject tag];
				if([[tag objectForKey:@"value"] isEqualTo:[item value]])
				{
					triangle = anObject;
				}
			}
		}
		
		NSRect triangleRect = NSMakeRect(cellFrame.origin.x - 16, cellFrame.origin.y + 2, 16, 16);
		
		// Add triangle if neccessary
		if([triangle superview] != controlView)
		{
			triangle = [[[PAImageButton alloc] initWithFrame:triangleRect] autorelease];
			[triangle setImage:[NSImage imageNamed:@"CollapsedTriangleWhite"] forState:PAOffState];
			[triangle setImage:[NSImage imageNamed:@"ExpandedTriangleWhite"] forState:PAOnState];
			[triangle setImage:[NSImage imageNamed:@"ExpandedTriangleWhite_Pressed"] forState:PAOnHighlightedState];
			[triangle setImage:[NSImage imageNamed:@"CollapsedTriangleWhite_Pressed"] forState:PAOffHighlightedState];		
			
			[triangle setButtonType:PASwitchButton];
			[triangle setState:PAOnState];
			[triangle setAction:@selector(triangleClicked:)];
			[triangle setTarget:[[self controlView] delegate]];
			
			// Add references to PAImageButton's tag for later usage
			NSMutableDictionary *tag = [triangle tag];
			[tag setObject:[item value] forKey:@"value"];
			
			[controlView addSubview:triangle];  
			
			// needs to be set after adding as subview
			[[triangle cell] setShowsBorderOnlyWhileMouseInside:YES];
		} else {
			[triangle setFrame:triangleRect];
		}
		
		// Change images on highlight and deselect
		if(![self isHighlighted])
		{
			[triangle setImage:[NSImage imageNamed:@"triangle-gray-collapsed"] forState:PAOffState];
			[triangle setImage:[NSImage imageNamed:@"triangle-gray-expanded"] forState:PAOnState];
			[triangle setImage:[NSImage imageNamed:@"triangle-gray-expanded-on"] forState:PAOnHighlightedState];
			[triangle setImage:[NSImage imageNamed:@"triangle-gray-collapsed-on"] forState:PAOffHighlightedState];		
		}
		else
		{
			[triangle setImage:[NSImage imageNamed:@"CollapsedTriangleWhite"] forState:PAOffState];
			[triangle setImage:[NSImage imageNamed:@"ExpandedTriangleWhite"] forState:PAOnState];
			[triangle setImage:[NSImage imageNamed:@"ExpandedTriangleWhite_Pressed"] forState:PAOnHighlightedState];
			[triangle setImage:[NSImage imageNamed:@"CollapsedTriangleWhite_Pressed"] forState:PAOffHighlightedState];		
		}
		
		// Does triangle's current state match the cell's state?	
		if([triangle state] != PAOnHoveredState &&
		   [triangle state] != PAOffHoveredState &&
		   [triangle state] != PAOnHighlightedState &&
		   [triangle state] != PAOffHighlightedState)
		{
			if([(NSOutlineView *)[triangle superview] isItemExpanded:item])
				[triangle setState:PAOnState];
			else
				[triangle setState:PAOffState];
		}
	}
	
	// Font attributes
	NSMutableDictionary *fontAttributes = [NSMutableDictionary dictionaryWithCapacity:3];
	
	NSMutableParagraphStyle *paraStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
	[paraStyle setLineBreakMode:NSLineBreakByTruncatingMiddle];		
	
	[fontAttributes setObject:paraStyle forKey:NSParagraphStyleAttributeName];	
	
	if([item isHeading]) 
	{
		NSColor *textColor = [NSColor colorWithDeviceRed:(57.0/255.0) green:(67.0/255.0) blue:(81.0/255.0) alpha:1.0];
		NSFont *font = [NSFont boldSystemFontOfSize:11];
		
		NSShadow *shdw = [[[NSShadow alloc] init] autorelease];
		NSSize shadowOffset;
		if([controlView isFlipped]) { shadowOffset = NSMakeSize(0,-1.5); } else { shadowOffset = NSMakeSize(0,1.5); }
		[shdw setShadowOffset:shadowOffset];
		[shdw setShadowColor:[NSColor colorWithCalibratedWhite:0.95 alpha:1.0]];
		
		[fontAttributes setObject:textColor forKey:NSForegroundColorAttributeName];	
		[fontAttributes setObject:font forKey:NSFontAttributeName];
		[fontAttributes setObject:shdw forKey:NSShadowAttributeName];
		
		// Draw display name	
		NSAttributedString *label = [[[NSAttributedString alloc] initWithString:[[item displayName] uppercaseString]
																	attributes:fontAttributes] autorelease];	
		
		[label drawInRect:NSMakeRect(cellFrame.origin.x,
									 cellFrame.origin.y + cellFrame.size.height - [label size].height - 3,
									 cellFrame.size.width - 10.0,
									 cellFrame.size.height)];
	}
	else 
	{
		NSColor *textColor = [NSColor whiteColor];
		NSFont *font = [NSFont boldSystemFontOfSize:11];
		
		if(![self isHighlighted]) 
		{
			// This depends on whether it is used in an OutlineView or a TableView or somewhere else
			if([controlView isKindOfClass:[NSOutlineView class]])
			{
				if(![[(NSOutlineView *)controlView itemAtRow:[controlView editedRow]] isEqualTo:item])
				{
					textColor = [NSColor blackColor];
					font = [NSFont systemFontOfSize:11];
				}
			}
		}
		
		[fontAttributes setObject:textColor forKey:NSForegroundColorAttributeName];	
		[fontAttributes setObject:font forKey:NSFontAttributeName];
	
		// Draw display name	
		NSAttributedString *label = [[[NSAttributedString alloc] initWithString:[item displayName]
																	attributes:fontAttributes] autorelease];	
		
		[label drawInRect:NSMakeRect(cellFrame.origin.x,
									 cellFrame.origin.y + (cellFrame.size.height - [label size].height) / 2,
									 cellFrame.size.width - 10.0,
									 cellFrame.size.height)];
	} 
}


#pragma mark Renaming Stuff
- (void)selectWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject start:(int)selStart length:(int)selLength
{		
	NSTextView *editor = (NSTextView *)textObj;
	//[editor setFieldEditor:YES];
	
	NSRect frame = aRect;
	//frame.origin.x += 0;
	frame.origin.y += 2;
	frame.size.width -= 5;
	
	[editor setString:[item displayName]];
	
	[editor setDelegate:controlView];
	
	[editor selectAll:self];

	[editor sizeToFit];
	
	//NSLayoutManager *layoutManager = [editor layoutManager];
	//[layoutManager boundingRectForGlyphRange:NSMakeRange(0, [layoutManager numberOfGlyphs]) inTextContainer:[editor textContainer]];
		
	//frame.size.width = [layoutManager usedRectForTextContainer:[editor textContainer]].size.width;
	frame.size.height = 16;
	
	[editor setFrame:frame];	
	
	// Set up scrollview
	NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:frame];
	
	[scrollView setBorderType:NSNoBorder];	
	[scrollView setHasVerticalScroller:NO];	
	[scrollView setHasHorizontalScroller:NO];	
	[scrollView setAutoresizingMask:NSViewWidthSizable];
	
	// Put scrollview and editor together
	[scrollView setDocumentView:editor];
	[editor scrollPoint:NSMakePoint(250.0, 0.0)];
	
	[controlView addSubview:scrollView];
	
	[[controlView window] makeFirstResponder:scrollView];
}

- (void)endEditing:(NSText *)textObj
{
	// nothing yet
}


#pragma mark Accessors
- (id)objectValue
{
	return item;
}

- (void)setObjectValue:(id <NSCopying>)object
{
	// weak reference
	item = object;
}

@end
