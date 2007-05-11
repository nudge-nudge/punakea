//
//  PAInfoPaneSingleSelectionView.m
//  punakea
//
//  Created by Daniel on 10.05.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PAInfoPaneSingleSelectionView.h"


@interface PAInfoPaneSingleSelectionView (PrivateAPI)

- (void)repositionFields;

@end



@implementation PAInfoPaneSingleSelectionView

#pragma mark Init + Dealloc
- (id)initWithFrame:(NSRect)frame 
{
    self = [super initWithFrame:frame];
    if(self)
	{        
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(frameDidChange:)
													 name:NSViewFrameDidChangeNotification
												   object:self];		
    }
    return self;
}

- (void)awakeFromNib
{
	// Empty all fields
	[kindField setStringValue:@""];
	[sizeField setStringValue:@""];
	[createdField setStringValue:@""];
	[modifiedField setStringValue:@""];
	[lastOpenedField setStringValue:@""];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super dealloc];
}


#pragma mark Drawing
- (void)drawRect:(NSRect)rect
{	
	[[NSColor whiteColor] set];
	NSRectFill(rect);
}


#pragma mark Misc
- (void)repositionFields
{
	// Remember: We're working in a non-flipped environment!
	
	float lineHeight = 16.0;
	
	NSSize kfContentSize = [kindField minSizeForContent];
	NSRect kfFrame = [kindField frame];
	
	// Set frame for first field and label "Size"
	NSPoint o = [sizeField frame].origin;
	o.y = kfFrame.origin.y + kfFrame.size.height - kfContentSize.height - lineHeight;
	[sizeField setFrameOrigin:o];
	
	o.x = [sizeLabel frame].origin.x;
	[sizeLabel setFrameOrigin:o];
	
	// Set frame for all other fields plus their labels
	NSArray *textFields = [NSArray arrayWithObjects:createdField, modifiedField,
		lastOpenedField, nil];
	NSArray *labels = [NSArray arrayWithObjects:createdLabel, modifiedLabel, 
		lastOpenedLabel, nil];
	
	for(int i = 0; i < [textFields count]; i++)
	{
		NSTextView *textField = [textFields objectAtIndex:i];
		NSTextView *label = [labels objectAtIndex:i];
		
		// Set frame for textfield
		o.x = [textField frame].origin.x;
		o.y -= lineHeight;
		[textField setFrameOrigin:o];
		
		o.x = [label frame].origin.x;
		[label setFrameOrigin:o];
	}	
	
	// Set frame for tagField
	o.x = [tagField frame].origin.x;
	o.y -= 2 * lineHeight;
	[tagField setFrameOrigin:o];
	
	[self setNeedsDisplay:YES];
}


#pragma mark Notifications
- (void)frameDidChange:(NSNotification *)notification
{
	[self repositionFields];
}


#pragma mark Accessors
- (NNFile *)file{
	return file;
}

- (void)setFile:(NNFile *)aFile
{
	[file release];
	file = [aFile retain];
	
	// Update fields
	[kindField setStringValue:[file kind]];
	
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];	
	[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	
	[createdField setStringValue:[dateFormatter saveStringFromDate:[file creationDate]]];
	[modifiedField setStringValue:[dateFormatter saveStringFromDate:[file modificationDate]]];
	[lastOpenedField setStringValue:[dateFormatter saveStringFromDate:[file lastUsedDate]]];
	
	[self repositionFields];
}

@end
