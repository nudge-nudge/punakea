//
//  PASelectedTagsView.m
//  punakea
//
//  Created by Johannes Hoffart on 31.03.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PASelectedTagsView.h"

@interface PASelectedTagsView (PrivateAPI)

- (void)drawBackground;
- (void)updateView;

@end

@implementation PASelectedTagsView

#pragma mark init
- (id)initWithFrame:(NSRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) {
		cellWidth = 80;
		cellMaxWidth = 120;
		cellHeight = 20;
		cellMaxHeight = 40;
		
		//settings
		[self setBackgroundColor:[NSColor whiteColor]];
		[self setMode:NSHighlightModeMatrix];
		[self setSelectionByRect:NO];
    }
    return self;
}

- (void)awakeFromNib
{
	[selectedTagsController addObserver:self
							 forKeyPath:@"arrangedObjects"
								options:0
								context:NULL];
}

#pragma mark drawing
- (void)drawRect:(NSRect)rect 
{
	[self updateView];
	[super drawRect:rect];
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

	// get some useful values
	NSSize bounds = [self bounds].size;
	
	int tagCount = [[selectedTagsController arrangedObjects] count];
	
	float displayWidth, displayHeight;
	int numberOfTagsInRow;
		
	// if tags fit with their maxium width, draw them
	if ( tagCount <= (bounds.width / cellMaxWidth) )
	{
		displayWidth = cellMaxWidth;
		displayHeight = cellMaxHeight;
		numberOfTagsInRow = tagCount;
	}
	// if the fit with their minimum width, stretch em
	else if (tagCount <= (bounds.width / cellWidth) )
	{
		displayWidth = ( (float)bounds.width / (float)tagCount);
		displayHeight = cellMaxHeight;
		numberOfTagsInRow = tagCount;
	}			 
	// if they overflow (2+ rows needed), draw rest of rows with stretched width
	else
	{
		numberOfTagsInRow = (bounds.width / cellWidth);
		displayWidth = ( (float)bounds.width / (float)numberOfTagsInRow);
		displayHeight = cellHeight;
	}
	
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
			
			PATag *tag = [[selectedTagsController arrangedObjects] objectAtIndex:counter];
			NSButtonCell *cell = [[NSButtonCell alloc] initTextCell:[tag name]];
			[cell setBezelStyle:NSRecessedBezelStyle];
			[self putCell:cell atRow:i column:j];
			[cell release];
			counter++;
		}
	}
}

/**
bound to selectedTags
 */
- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object 
                        change:(NSDictionary *)change
                       context:(void *)context
{
	if ([keyPath isEqual:@"arrangedObjects"]) 
	{
		[self updateView];
	}
}
@end
