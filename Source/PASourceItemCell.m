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
	// Font attributes
	NSMutableDictionary *fontAttributes = [NSMutableDictionary dictionaryWithCapacity:3];
	
	NSMutableParagraphStyle *paraStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
	[paraStyle setLineBreakMode:NSLineBreakByTruncatingMiddle];		
	
	[fontAttributes setObject:paraStyle forKey:NSParagraphStyleAttributeName];	
	
	if(![item isHeading]) 
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
		NSAttributedString *label = [[NSAttributedString alloc] initWithString:[item displayName]
																	attributes:fontAttributes];	
		
		[label drawInRect:NSMakeRect(cellFrame.origin.x,
									 cellFrame.origin.y + (cellFrame.size.height - [label size].height) / 2,
									 cellFrame.size.width - 10.0,
									 cellFrame.size.height)];
	} 
	else
	{		
		NSColor *textColor = [NSColor colorWithDeviceRed:(57.0/255.0) green:(67.0/255.0) blue:(81.0/255.0) alpha:1.0];
		NSFont *font = [NSFont systemFontOfSize:11];	
		
		[fontAttributes setObject:textColor forKey:NSForegroundColorAttributeName];	
		[fontAttributes setObject:font forKey:NSFontAttributeName];
		
		// Draw display name	
		NSAttributedString *label = [[NSAttributedString alloc] initWithString:[[item displayName] uppercaseString]
																	attributes:fontAttributes];	
		
		[label drawInRect:NSMakeRect(cellFrame.origin.x,
									 cellFrame.origin.y + cellFrame.size.height - [label size].height - 3,
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
	
	[editor setBackgroundColor:[NSColor whiteColor]];
	[editor setFocusRingType:NSFocusRingTypeNone];
	
	[editor setFont:[NSFont systemFontOfSize:11]];
	[editor setString:[item displayName]];
	[editor setTextContainerInset:NSMakeSize(-3,1)];
	
	[editor setDelegate:controlView];
	
	[editor selectAll:self];
	//[editor setSelectedRange:NSMakeRange([editor selectedRange].length, 0)];

	[editor sizeToFit];
	
	//NSLayoutManager *layoutManager = [editor layoutManager];
	//[layoutManager boundingRectForGlyphRange:NSMakeRange(0, [layoutManager numberOfGlyphs]) inTextContainer:[editor textContainer]];
		
	//frame.size.width = [layoutManager usedRectForTextContainer:[editor textContainer]].size.width;
	frame.size.height = 16;
	
	[editor setFrame:frame];	
	
	[editor setMinSize:NSMakeSize(0.0, 16.0)];
	[editor setMaxSize:NSMakeSize(FLT_MAX, 16.0)];
	
	[editor setVerticallyResizable:NO];
	[editor setHorizontallyResizable:YES];
	
	[editor setAutoresizingMask:NSViewWidthSizable];
	
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
