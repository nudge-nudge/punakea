// Copyright (c) 2006-2012 nudge:nudge (Johannes Hoffart & Daniel Bär). All rights reserved.
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

#import "PAInfoPaneMultipleSelectionView.h"


@implementation PAInfoPaneMultipleSelectionView

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
	[fromField setStringValue:@""];
	[toField setStringValue:@""];
	[itemsField setStringValue:@""];
	[sizeField setStringValue:@""];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[files release];
	
	[super dealloc];
}


#pragma mark Misc
- (void)repositionFields
{
	// Remember: We're working in a non-flipped environment!
	
	BOOL oneDate = [[fromField stringValue] isEqualTo:[toField stringValue]];
	
	// Adjust text of "From" label
	if(oneDate)
		[fromLabel setStringValue:NSLocalizedStringFromTable(@"DATE", @"Global", nil)];
	else
		[fromLabel setStringValue:NSLocalizedStringFromTable(@"FROM", @"Global", nil)];
	
	// Hide row for "To" if there's only one date
	if(oneDate)
	{
		[toLabel setHidden:YES];
		[toField setHidden:YES];
	} else {
		[toLabel setHidden:NO];
		[toField setHidden:NO];
	}
	
	NSPoint o = [fromField frame].origin;
	if(!oneDate)
		o.y -= LINE_HEIGHT;
	
	// Set frame for all other fields plus their labels
	NSArray *textFields = [NSArray arrayWithObjects:itemsField, sizeField, nil];
	NSArray *labels = [NSArray arrayWithObjects:itemsLabel, sizeLabel, nil];
	
	for(NSInteger i = 0; i < [textFields count]; i++)
	{
		NSTextView *textField = [textFields objectAtIndex:i];
		NSTextView *label = [labels objectAtIndex:i];
		
		// Set frame for textfield
		NSPoint p = [textField frame].origin;
		p.y = o.y - LINE_HEIGHT;
		[textField setFrameOrigin:p];
		
		p.x = [label frame].origin.x;
		[label setFrameOrigin:p];
		
		o = p;
	}
	
	[self setNeedsDisplay:YES];
}


#pragma mark Notifications
- (void)frameDidChange:(NSNotification *)notification
{
	[self repositionFields];
}


#pragma mark Accessors
- (NSArray *)files
{
	return [NSArray arrayWithArray:files];
}

- (void)setFiles:(NSArray *)theFiles
{
	[files release];
	files = [[NSMutableArray alloc] initWithArray:theFiles];
	
	// Update fields
	
	NSString *s = [NSString stringWithFormat:@"%lu %@", [files count],
		NSLocalizedStringFromTable(@"FILES", @"Global", nil)];
	[itemsField setStringValue:s];
	
	NSEnumerator *e = [files objectEnumerator];
	NNFile *file;
	
	fromDate = nil;
	toDate = nil;
	unsigned long long size = 0;
	
	while(file = [e nextObject])
	{
		NSDate *creationDate = [file creationDate];
		
		if(creationDate)
		{
			if(fromDate)
				fromDate = [fromDate earlierDate:creationDate];
			else 
				fromDate = creationDate;
			
			if(toDate)
				toDate = [toDate laterDate:creationDate];
			else
				toDate = creationDate;
		}
		
		// As we are calcing the file size on disk, each file needs to be of at least 4096 bytes
		if([file size] < 4096)
			size += 4096;
		else
			size += [file size];
	}

	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];	
	[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	
	[fromField setStringValue:[dateFormatter stringFromDate:fromDate]];
	[toField setStringValue:[dateFormatter stringFromDate:toDate]];
	
	NSNumberFormatter *numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
	[numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	
	s = [NSString stringWithFormat:
		NSLocalizedStringFromTable(@"FILE_SIZE_ON_DISK", @"Global", nil),
		[numberFormatter stringFromFileSize:size]];
	
	[sizeField setStringValue:s];
	
	[self repositionFields];
}

@end
