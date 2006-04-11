#import "PAResultsOutlineView.h"

@implementation PAResultsOutlineView

#pragma mark Init
- (void)awakeFromNib
{
	[self setIndentationPerLevel:0.0];
	[self setIntercellSpacing:NSMakeSize(0,1)];
	[[self delegate] setOutlineView:self];
}


#pragma mark Instance Methods
- (NSRect)frameOfCellAtColumn:(int)columnIndex row:(int)rowIndex
{
	/*if([self levelForRow:rowIndex] == 0)
	{
		// Ignore intercell spacing for group cells
		NSRect rect = [super frameOfCellAtColumn:columnIndex row:rowIndex];
		NSSize intercellSpacing = [self intercellSpacing];
		
		rect.origin.x = rect.origin.x - intercellSpacing.width;
		rect.origin.y = rect.origin.y - intercellSpacing.height;
		rect.size.width = rect.size.width + 2 * intercellSpacing.width;
		rect.size.height = rect.size.height + intercellSpacing.height;
		
		return rect;
	}*/
	
	return [super frameOfCellAtColumn:columnIndex row:rowIndex];
}


#pragma mark Actions
- (void)reloadData
{
    while ([[self subviews] count] > 0)
    {
		[[[self subviews] lastObject] removeFromSuperviewWithoutNeedingDisplay];
    }
	
	//NSArray *collapsedGroups = [[userDefaults objectForKey:@"GroupItems"] objectForKey:@"CollapsedGroups"];
	
	/*int i, j;
	for(i = 0; i < [self numberOfRows]; i++)
	{			
		if([self levelForRow:i] == 0)
		{
			BOOL isCollapsed = NO;
			for(j = 0; j < [collapsedGroups count]; j++)
			{
				if([[collapsedGroups objectAtIndex:j] isEqualToString:[[self itemAtRow:i] value]])
				{
					isCollapsed = YES;		
					break;
				}
			}				
			if(!isCollapsed) [self expandItem:[self itemAtRow:i]];
		}
	}*/
    
    [super reloadData];
}


#pragma mark Notifications
- (void)queryNote:(NSNotification *)note
{	
	if ([[note name] isEqualToString:NSMetadataQueryGatheringProgressNotification] ||
		[[note name] isEqualToString:NSMetadataQueryDidUpdateNotification] ||
		[[note name] isEqualToString:NSMetadataQueryDidFinishGatheringNotification])
	{
		[self reloadData];
	}
}


#pragma mark Accessors
- (NSMetadataQuery *)query
{
	return query;
}

- (void)setQuery:(NSMetadataQuery *)aQuery
{
	query = aQuery;
	NSNotificationCenter *nf = [NSNotificationCenter defaultCenter];
    [nf addObserver:self selector:@selector(queryNote:) name:nil object:query];
	[[self delegate] setQuery:query];
}

@end
