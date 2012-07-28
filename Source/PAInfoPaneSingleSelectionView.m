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
	[[NSNotificationCenter defaultCenter] removeObserver:file];
	
	[file release];
	
	[super dealloc];
}


#pragma mark Misc
- (void)repositionFields
{
	// Remember: We're working in a non-flipped environment!
	
	NSSize kfContentSize = [kindField minSizeForContent];
	NSRect kfFrame = [kindField frame];
	
	// Set "To" hidden if there are files from only one date
	NSPoint o = [sizeField frame].origin;
	o.y = kfFrame.origin.y + kfFrame.size.height - kfContentSize.height - LINE_HEIGHT;
	[sizeField setFrameOrigin:o];
	
	o.x = [sizeLabel frame].origin.x;
	[sizeLabel setFrameOrigin:o];
	
	// Set frame for all other fields plus their labels
	NSArray *textFields = [NSArray arrayWithObjects:createdField, modifiedField,
		lastOpenedField, nil];
	NSArray *labels = [NSArray arrayWithObjects:createdLabel, modifiedLabel, 
		lastOpenedLabel, nil];
	
	for(NSInteger i = 0; i < [textFields count]; i++)
	{
		NSTextView *textField = [textFields objectAtIndex:i];
		NSTextView *label = [labels objectAtIndex:i];
		
		// Set frame for textfield
		o.x = [textField frame].origin.x;
		o.y -= LINE_HEIGHT;
		[textField setFrameOrigin:o];
		
		o.x = [label frame].origin.x;
		[label setFrameOrigin:o];
	}
	
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
	
	// Threaded file size computation
//	[[NSNotificationCenter defaultCenter] removeObserver:self name:NNFileSizeChangeOperation object:file];
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sizeChanged:) name:NNFileSizeChangeOperation object:file];	
//	
//	[file performSelectorInBackground:@selector(computeSizeThreaded) withObject:nil];
//	[sizeField setStringValue:@"Calculating..."];
	
	NSNumberFormatter *numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
	[numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	
	NSNumber *sizeNumber = [NSNumber numberWithUnsignedLongLong:[file size]];
	unsigned long long size = [sizeNumber unsignedLongLongValue];
	
	NSString *s = [NSString stringWithFormat:
						NSLocalizedStringFromTable(@"FILE_SIZE_ON_DISK", @"Global", nil),
						[numberFormatter stringFromFileSize:size]];
	
	[sizeField setStringValue:s];
	
	[self repositionFields];
}

//- (void)sizeChanged:(NSNotification *)notification
//{
//	NSNumberFormatter *numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
//	[numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
//	
//	NSNumber *sizeNumber = (NSNumber *)[[notification userInfo] valueForKey:@"size"];
//	unsigned long long size = [sizeNumber unsignedLongLongValue];
//	
//	NSString *s = [NSString stringWithFormat:
//				   NSLocalizedStringFromTable(@"FILE_SIZE_ON_DISK", @"Global", nil),
//				   [numberFormatter stringFromFileSize:size]];
//	
//	[sizeField setStringValue:s];
//}

@end
