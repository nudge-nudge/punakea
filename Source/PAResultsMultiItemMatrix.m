//
//  PAResultsMultiItemMatrix.m
//  punakea
//
//  Created by Daniel on 17.04.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAResultsMultiItemMatrix.h"


@implementation PAResultsMultiItemMatrix

#pragma mark Init + Dealloc
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self setCellClass:[PAResultsMultiItemThumbnailCell class]];
		[self renewRows:1 columns:0];
		[self setIntercellSpacing:NSMakeSize(15,0)];
		[self setMode:NSHighlightModeMatrix];
		[self setTarget:self];
		[self setCellSize:[[self cellClass] cellSize]];
    }
    return self;
}

- (void)dealloc
{
	if(item) [item release];
	[super dealloc];
}


#pragma mark Actions
- (void)displayCellsForItems
{
	[self removeRow:0];
	[self renewRows:1 columns:0];
	
	NSEnumerator *enumerator = [[item items] objectEnumerator];
	NSMetadataItem *anObject;
	
	int column = 0;
	while(anObject = [enumerator nextObject])
	{
		PAResultsMultiItemThumbnailCell *cell = [[[PAResultsMultiItemThumbnailCell alloc] initTextCell:[anObject valueForAttribute:@"kMDItemDisplayName"]] autorelease];
		
		if([self numberOfColumns] == 3)	[self addRow];
		if(column == 2) column = 0;
		
		// Add columns when adding cells in first row
		if([self numberOfRows] == 1)
		{
			[self addColumnWithCells:[NSArray arrayWithObject:cell]];
		} else {
			[self putCell:cell atRow:[self numberOfRows]-1 column:column];
			column++;
		}
	}
}


#pragma mark Accessors
- (PAResultsMultiItem *)item
{
	return item;
}

- (void)setItem:(PAResultsMultiItem *)anItem
{
	item = [anItem retain];
	[self displayCellsForItems];
}

@end
