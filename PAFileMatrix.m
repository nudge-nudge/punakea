//
//  PAFileMatrix.m
//  punakea
//
//  Created by Daniel on 08.03.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAFileMatrix.h"


@interface PAFileMatrix (PrivateAPI)

//- (PAFileMatrixGroupCell *)insertGroupCell:(PAFileMatrixGroupCell *)cell atRow:(int)row;
- (void)insertItemCell:(PAFileMatrixItemCell *)cell atRow:(int)row;

@end

@implementation PAFileMatrix

#pragma mark Init + Dealloc
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self setCellClass:[NSTextFieldCell class]];
		[self renewRows:0 columns:1];
		groupRowDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
	if(groupRowDict) { [groupRowDict release]; }
	[super dealloc];
}

- (void)drawRect:(NSRect)rect
{
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

- (void)updateView
{
	int i, j;
	int row = -1;
	
	NSArray *groupedResults = [query groupedResults];
	for (i = 0; i < [groupedResults count]; i++)
	{
		row++;
		NSMetadataQueryResultGroup *group = [groupedResults objectAtIndex:i];
		
		// Temp
		//NSLog([[NSNumber numberWithInt:row] stringValue]);
		//NSLog([group value]);
		
		//PAFileMatrixGroupCell *groupCell = [[[PAFileMatrixGroupCell alloc] initTextCell:[group value]] autorelease];
		//PAFileMatrixGroupCell *thisCell = [self insertGroupCell:groupCell atRow:row];
		PAFileMatrixGroupCell *thisCell = [self insertGroupCell:[group value] atRow:row];

		/*if([thisCell isExpanded]) {
			for (j = 0; j < [group resultCount]; j++)
			{
				row++;
				NSMetadataItem *item = [group resultAtIndex:j];
				NSString *itemPath = [item valueForAttribute:@"kMDItemPath"];
				PAFileMatrixItemCell* itemCell = [[[PAFileMatrixItemCell alloc] initTextCell:itemPath] autorelease];
				[itemCell setMetadataItem:item];
				[self insertItemCell:itemCell atRow:row];
			}
		}*/
	}
	
	// Delete old rows
	if((row+1) <  [self numberOfRows])
	{
		for(i = row+1; i < [self numberOfRows]; i++)
		{
			// Delete dict entry
			if([[[self cellAtRow:i column:0] class] isEqualTo:[PAFileMatrixGroupCell class]])
			{
				[groupRowDict removeObjectForKey:[[self cellAtRow:i column:0] key]];
			}
			[self removeRow:i];
		}
	}
	
	[self setNeedsDisplay];
}

- (void)resetView
{
	/*int i;
	for(i = 0; i < [self numberOfRows]; i++)
	{
		[self removeRow:i];
	}*/
	[groupRowDict removeAllObjects];
}

/*- (void)updateViewNEW
{
	int i;
	
	NSArray *groupedResults = [query groupedResults];
	for (i = 0; i < [groupedResults count]; i++)
	{
		NSMetadataQueryResultGroup *group = [groupedResults objectAtIndex:i];	
		
		BOOL doInsert = YES;
		if([[[self cellAtRow:i column:0] class] isEqualTo:[PAFileMatrixGroupCell class]])
		{
			if([[[self cellAtRow:i column:0] key] isEqualTo:[group value]]) {
				doInsert = NO;
			}
		}
		
		if(doInsert) {
			PAFileMatrixGroupCell *cell = [[[PAFileMatrixGroupCell alloc] initTextCell:[group value]] autorelease];
			//NSButtonCell *cell = [[[NSButtonCell alloc] initTextCell:@"huhu"] autorelease];
			[self insertRow:i];
			[self putCell:cell atRow:i column:0];
		}
		
		if([[self cellAtRow:i column:0] isExpanded])
		{
			[[self cellAtRow:i column:0] expand];
		}
	}
} */

- (PAFileMatrixGroupCell*)insertGroupCell:(NSString*)value atRow:(int)row
{
	if([groupRowDict objectForKey:value]) {
		// This group already exists, as groups' values are unique
		
		// TODO: Move cell to specified row!
		// Puh, indices vary if cell is collapsed/expanded...
		NSNumber *thisRowNumber = [groupRowDict objectForKey:value];
		int thisRow = [thisRowNumber intValue];
		if(thisRow != row)
		{
			[self insertRow:row];
			[self putCell:[self cellAtRow:thisRow column:0] atRow:row column:0];
			[self removeRow:thisRow+1];
		}
		
		return [self cellAtRow:[[groupRowDict objectForKey:value] intValue] column:0];
	}
	else
	{
		// This group needs to be created at the specified row		
		
		// TODO Shift other dict values
		NSArray *allKeys = [groupRowDict allKeys];
		int i;
		for (i = 0; i < [allKeys count]; i++)
		{
			NSNumber *thisRowNumber = [groupRowDict objectForKey:[allKeys objectAtIndex:i]];
			int thisRow = [thisRowNumber intValue];
			if(thisRow >= row)
			{
				[groupRowDict setObject:[NSNumber numberWithInt:(thisRow+1)] forKey:[allKeys objectAtIndex:i]];
			}	
		}	
		
		[groupRowDict setObject:[NSNumber numberWithInt:row] forKey:value];
		
		PAFileMatrixGroupCell *cell = [[[PAFileMatrixGroupCell alloc] initTextCell:value] autorelease];
		[self insertRow:row];
		[self putCell:cell atRow:row column:0];
		return cell;
	}
}

/* DEPRECATED
- (PAFileMatrixGroupCell *)insertGroupCell:(PAFileMatrixGroupCell *)cell atRow:(int)row
{
	if ([self numberOfRows] <= row ||
	    ![[cell key] isEqualTo:[[self cellAtRow:row column:0] key]])
	{		
		[self insertRow:row];
		[self putCell:cell atRow:row column:0];
	}
	return [self cellAtRow:row column:0];
} */

- (void)insertItemCell:(PAFileMatrixItemCell *)cell atRow:(int)row
{
	if ([self numberOfRows] <= row ||
	    ![[cell key] isEqualTo:[[self cellAtRow:row column:0] key]])
	{		
		[self insertRow:row];
		[self putCell:cell atRow:row column:0];
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
							PAFileMatrixItemCell* itemCell = [[[PAFileMatrixItemCell alloc] initTextCell:itemPath] autorelease];
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
@end