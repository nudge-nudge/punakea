//
//  PAFileMatrix.m
//  punakea
//
//  Created by Daniel on 08.03.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAFileMatrix.h"


@interface PAFileMatrix (PrivateAPI)

- (PAFileMatrixGroupCell *)insertGroupCell:(PAFileMatrixGroupCell *)cell atRow:(int)row;
- (void)insertItemCell:(PAFileMatrixItemCell *)cell atRow:(int)row;

@end

@implementation PAFileMatrix

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		[self setCellClass:[NSTextFieldCell class]];
		[self renewRows:0 columns:1];
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
	// Update cell size
	[self setCellSize:NSMakeSize(rect.size.width,20)];

	// Draw background
	NSRect bounds = [self bounds];
	[[NSColor whiteColor] set];
	[NSBezierPath fillRect:bounds];
	
	[super drawRect:rect];
}

- (void)setQuery:(NSMetadataQuery*)aQuery
{
	query = aQuery;
	NSNotificationCenter *nf = [NSNotificationCenter defaultCenter];
    [nf addObserver:self selector:@selector(queryNote:) name:nil object:query];
}

// DEPRECATED - TODO: insert grouprows and then expand each grouprow with expandGroupCell:
- (void)updateViewOLD
{
	int i, j;
	int row = -1;
	
	NSArray *groupedResults = [query groupedResults];
	for (i = 0; i < [groupedResults count]; i++)
	{
		row++;
		NSMetadataQueryResultGroup *group = [groupedResults objectAtIndex:i];
		
		PAFileMatrixGroupCell* groupCell = [[PAFileMatrixGroupCell alloc] initTextCell:[group value]];
		PAFileMatrixGroupCell* thisCell = [self insertGroupCell:groupCell atRow:row];
		//[groupCell release];

		if([thisCell isExpanded]) {
			for (j = 0; j < [group resultCount]; j++)
			{
				row++;
				NSMetadataItem *item = [group resultAtIndex:j];
				NSString *itemPath = [item valueForAttribute:@"kMDItemPath"];
				PAFileMatrixItemCell* itemCell = [[PAFileMatrixItemCell alloc] initTextCell:itemPath];
				[itemCell setMetadataItem:item];
				[self insertItemCell:itemCell atRow:row];
			}
		}
	}
	
	[self renewRows:(row+1) columns:1];	
	[self setNeedsDisplay];
}

- (void)resetView
{
	int i;	
	for (i = 0; i < [self numberOfRows]; i++)
	{
		[[self cellAtRow:i column:0] rel];
		[self removeRow:i];
	}
}

- (void)updateView
{
	[self updateViewOLD];
}

- (PAFileMatrixGroupCell *)insertGroupCell:(PAFileMatrixGroupCell *)cell atRow:(int)row
{
	if ([self numberOfRows] <= row ||
	    ![[cell key] isEqualTo:[[self cellAtRow:row column:0] key]])
	{		
		[self insertRow:row];
		[self putCell:cell atRow:row column:0];
		return cell;
	} else {
		return [self cellAtRow:row column:0];
	}
}

- (void)insertItemCell:(PAFileMatrixItemCell *)cell atRow:(int)row
{
	if ([self numberOfRows] <= row ||
	    ![[cell key] isEqualTo:[[self cellAtRow:row column:0] key]])
	{		
		[self insertRow:row];
		[self putCell:cell atRow:row column:0];
	} else {
		//[cell release];
	}
}

- (void)expandGroupCell:(PAFileMatrixGroupCell *)cell
{
	int i, j, k;

	for (i = 0; i < [self numberOfRows]; i++)
	{
		if([[[self cellAtRow:i column:0] class] isEqualTo:[PAFileMatrixGroupCell class]])
		{
			PAFileMatrixGroupCell* thisCell = [self cellAtRow:i column:0];
			if([thisCell isEqualTo:cell])
			{
				NSArray *groupedResults = [query groupedResults];
				for (j = 0; j < [groupedResults count]; j++)
				{
					NSMetadataQueryResultGroup *group = [groupedResults objectAtIndex:j];
					
					if([[group value] isEqualTo:[cell key]])
					{
						for (k = 0; k < [group resultCount]; k++)
						{
							NSMetadataItem *item = [group resultAtIndex:k];
							NSString *itemPath = [item valueForAttribute:@"kMDItemPath"];
							PAFileMatrixItemCell* itemCell = [[PAFileMatrixItemCell alloc] initTextCell:itemPath];
							[itemCell setMetadataItem:item];
							[self insertItemCell:itemCell atRow:(i+1+k)];
						}
					}
				}
				break;
			}
		}
	}
	
	[self setNeedsDisplay];
}

- (void)collapseGroupCell:(PAFileMatrixGroupCell *)cell
{
	int i;
	int firstIndexWhenRemovingRows;
	
	for (i = 0; i < [self numberOfRows]; i++)
	{
		if([[[self cellAtRow:i column:0] class] isEqualTo:[PAFileMatrixGroupCell class]])
		{
			PAFileMatrixGroupCell* thisCell = [self cellAtRow:i column:0];
			if([thisCell isEqualTo:cell])
			{
				firstIndexWhenRemovingRows = i+1;
				break;
			}
		}
	}
	
	while([[[self cellAtRow:firstIndexWhenRemovingRows column:0] class] isEqualTo:[PAFileMatrixItemCell class]])
	{
		[self removeRow:firstIndexWhenRemovingRows];
	}
	
	[self setNeedsDisplay];
} 

- (void)queryNote:(NSNotification *)note
{	
	if ([[note name] isEqualToString:NSMetadataQueryGatheringProgressNotification] ||
		[[note name] isEqualToString:NSMetadataQueryDidUpdateNotification] ||
		[[note name] isEqualToString:NSMetadataQueryDidFinishGatheringNotification])
	{
		[self updateView];
	}
	
	if ([[note name] isEqualToString:NSMetadataQueryDidStartGatheringNotification])
	{
		[self resetView];
	}
}

- (void)dealloc
{
   [super dealloc];
}
@end