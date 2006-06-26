//
//  PASelectedTagsView.m
//  punakea
//
//  Created by Johannes Hoffart on 31.03.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PASelectedTagsView.h"

@interface PASelectedTagsView (PrivateAPI)

- (void)drawBorder;
- (void)updateView;

@end

@implementation PASelectedTagsView

#pragma mark init
- (id)initWithFrame:(NSRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) {
		//TODO externalize
		cellWidth = 80;
		cellMaxWidth = 120;
		cellHeight = 20;
		cellMaxHeight = [self bounds].size.height;
		
		//settings
		[self setMode:NSTrackModeMatrix];
		[self setSelectionByRect:NO];
		[self setIntercellSpacing:NSMakeSize(-1,-1)];
    }
    return self;
}

- (void)dealloc
{
	[selectedTags release];
	[super dealloc];
}

- (void)awakeFromNib
{
	selectedTags = [controller selectedTags];
	[selectedTags retain];
	
	[selectedTags addObserver:self
				   forKeyPath:@"selectedTags"
					  options:0
					  context:NULL];
}

/**
bound to selectedTags
 */
- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object 
                        change:(NSDictionary *)change
                       context:(void *)context
{
	if ([keyPath isEqual:@"selectedTags"]) 
	{
		[self updateView];
	}
}

#pragma mark drawing
- (void)drawRect:(NSRect)rect 
{
	[self drawBorder];
	
	// Doesn't work like this. We can't add new cells for every drawing!
	//[self updateView];

	[super drawRect:rect];
}

- (void)drawBorder
{
	NSRect bounds = [self bounds];
	[[NSColor whiteColor] set];
	[NSBezierPath fillRect:bounds];
	
	[[NSColor lightGrayColor] set];
	[NSBezierPath strokeRect:bounds];
}

- (void)updateView
{ 
	// remove all content
	int rows = [self numberOfRows];
	for (rows;rows>0;rows--)
	{
		int removeRow = rows - 1;
		[self removeRow:removeRow];
	}
	
	NSSize bounds = [self bounds].size;
	
	int tagCount = [selectedTags count];
	
	float displayWidth, displayHeight;
	int numberOfTagsInRow;
		
	float cellMaxWidthSum = tagCount * cellMaxWidth + (tagCount - 1) * [self intercellSpacing].width;
	float cellWidthSum = tagCount * cellWidth + (tagCount - 1) * [self intercellSpacing].width;
	
	// if tags fit with their maxium width, draw them
	if ( cellMaxWidthSum <= bounds.width )
	{
		displayWidth = cellMaxWidth;
		displayHeight = cellMaxHeight;
		numberOfTagsInRow = tagCount;
	}
	// if the fit with their minimum width, stretch em
	else if ( cellWidthSum <= bounds.width )
	{
		float spacingSum = tagCount * [self intercellSpacing].width;
		float totalAvailableWidth = (float)bounds.width - spacingSum;
		displayWidth = (totalAvailableWidth / (float)tagCount);
		displayHeight = cellMaxHeight;
		numberOfTagsInRow = tagCount;
	}			 
	// if they overflow (2+ rows needed), draw rest of rows with stretched width
	else
	{
		//TODO this isn't perfect but should do it ... improve!
		numberOfTagsInRow = (bounds.width / cellMaxWidth);
		float spacingSum = ( numberOfTagsInRow - 1 ) * [self intercellSpacing].width;
		float totalAvailableWidth = (float)bounds.width - spacingSum;
		displayWidth = ( totalAvailableWidth / (float)numberOfTagsInRow );
		displayHeight = cellHeight;
	}
	
	// SET FIX HEIGHT
	displayHeight = 22;
	
	// set cell size
	[self setCellSize:NSMakeSize(displayWidth,displayHeight)];
		
	int rowCount;
		
	if (tagCount % numberOfTagsInRow > 0)
	{
		rowCount = (tagCount / numberOfTagsInRow) + 1;
	}
	else
	{
		rowCount = (tagCount / numberOfTagsInRow);
	}
	
	// if the tags don't fill the entire row, lower numberOfTagsInRow
	if (tagCount < numberOfTagsInRow)
	{
		numberOfTagsInRow = tagCount;
	}
	
	[self renewRows:rowCount columns:numberOfTagsInRow];
	
	int i; //rows
	int j; //columns
	int counter = 0;
	
	for (i=0;i<rowCount;i++)
	{
		for (j=0;j<numberOfTagsInRow;j++)
		{
			// the last line may not be filled
			if (counter == tagCount)
				break;
			
			PATag *tag = [selectedTags tagAtIndex:counter];
			PASelectedTagCell *cell = [[PASelectedTagCell alloc] initTextCell:[tag name]];
			//[cell setBezelStyle:NSRecessedBezelStyle];
			[self putCell:cell atRow:i column:j];
			//[cell release];
			counter++;
		}
	}
}

@end
