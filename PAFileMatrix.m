//
//  PAFileMatrix.m
//  punakea
//
//  Created by Daniel on 08.03.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAFileMatrix.h"

@interface PAFileMatrix (PrivateAPI)

- (void)insertGroupCell:(PAFileMatrixGroupCell *)cell;
- (void)insertItemCell:(PAFileMatrixItemCell *)cell;

@end

@implementation PAFileMatrix

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

/* - (void)drawRect:(NSRect)rect {
    // Drawing code here.
} */

- (void)awakeFromNib{
	[self setCellClass:[NSTextFieldCell class]];
	[self renewRows:0 columns:1];
	[self setCellSize:NSMakeSize(400,20)];
	
	dictItemKind = [[NSMutableDictionary alloc] init];	
	dictItemPath = [[NSMutableDictionary alloc] init];
}

- (void)setQuery:(NSMetadataQuery*)aQuery
{
	query = aQuery;
	NSNotificationCenter *nf = [NSNotificationCenter defaultCenter];
    [nf addObserver:self selector:@selector(queryNote:) name:nil object:query];
}

- (void)updateView
{
	int i, j, k;
	
	NSArray *groupedResults = [query groupedResults];
	for (i = 0; i < [groupedResults count]; i++)
	{
		NSMetadataQueryResultGroup *group = [groupedResults objectAtIndex:i];
		
		PAFileMatrixGroupCell* groupCell = [[PAFileMatrixGroupCell alloc] initTextCell:[group value]];
		[self insertGroupCell:groupCell];
		
		NSArray *subgroups = [group subgroups];
		for (j = 0; j < [subgroups count]; j++)
		{
			NSMetadataQueryResultGroup *thisGroup = [subgroups objectAtIndex:j];

			for (k = 0; k < [thisGroup resultCount]; k++)
			{
				NSMetadataItem *item = [thisGroup resultAtIndex:k];
				NSString *displayName = [item valueForAttribute:@"kMDItemDisplayName"];
				PAFileMatrixItemCell* itemCell = [[PAFileMatrixItemCell alloc] initTextCell:displayName];
				[itemCell setMetadataItem:item];
				[self insertItemCell:itemCell];
			}
		}
	}
}

- (void)insertGroupCell:(PAFileMatrixGroupCell *)cell
{
	if (![dictItemKind objectForKey:[cell value]])
	{
		int tag = [self numberOfRows];
		[cell setTag:tag];
		
		// TODO When inserting row, update shift all other dict values!
		[self insertRow:tag];
		
		[self putCell:cell atRow:tag column:0];
		
		[dictItemKind setObject:[NSNumber numberWithInt:tag] forKey:[cell value]];
	}
}

- (void)insertItemCell:(PAFileMatrixItemCell *)cell
{
	NSMetadataItem *item = [cell metadataItem];
	NSString *path = [item valueForAttribute:@"kMDItemPath"];
	NSString *kind = [item valueForAttribute:@"kMDItemKind"];
	NSLog(kind);
	if(![dictItemPath objectForKey:path]) {
		int tag = [[dictItemKind objectForKey:kind] intValue] + 1;
		[cell setTag:tag];
		
		// TODO Like above!
		[self insertRow:tag];
		
		[self putCell:cell atRow:tag column:0];
		
		[dictItemPath setObject:[NSNumber numberWithInt:tag] forKey:path];
	}
}

- (void)queryNote:(NSNotification *)note
{
	NSLog(@"fileMatrix: note received");
	
	if ([[note name] isEqualToString:NSMetadataQueryGatheringProgressNotification] ||
		[[note name] isEqualToString:NSMetadataQueryDidUpdateNotification] ||
		[[note name] isEqualToString:NSMetadataQueryDidFinishGatheringNotification]) {
		[self updateView];
	}
}

- (void)dealloc
{
   if(dictItemKind) { [dictItemKind release]; }
   if(dictItemPath) { [dictItemPath release]; }
   [super dealloc];
}
@end