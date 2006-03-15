//
//  PAFileMatrix.m
//  punakea
//
//  Created by Daniel on 08.03.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAFileMatrix.h"
#import "PAFileMatrixKindCell.h"


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
		NSLog([group value]);
		NSArray *subgroups = [group subgroups];
		for (j = 0; j < [subgroups count]; j++)
		{
			NSMetadataQueryResultGroup *thisGroup = [subgroups objectAtIndex:j];
			NSLog([[thisGroup value] stringValue]);
			for (k = 0; k < [thisGroup resultCount]; k++)
			{
				NSMetadataItem *item = [thisGroup resultAtIndex:k];
				NSLog([item valueForAttribute:@"kMDItemPath"]);
			}
		}
	}
	
	for (i = 0; i < [query resultCount]; i++)
	{
		NSMetadataItem* item = [query resultAtIndex:i];
		
		// Check for item kind cell
		NSString* kind = [item valueForAttribute:@"kMDItemKind"];
		if (![dictItemKind objectForKey:kind])
		{
			int tag = [self numberOfRows];
			PAFileMatrixKindCell* kindCell = [[PAFileMatrixKindCell alloc] initTextCell:kind];
			[kindCell setTag:tag];
			
			// TODO When inserting row, update shift all other dict values!
			[self insertRow:tag];
			
			[self putCell:kindCell atRow:tag column:0];
			
			[dictItemKind setObject:[NSNumber numberWithInt:tag] forKey:kind];
		}
		
		// Check for file cell
		NSString* path = [item valueForAttribute:@"kMDItemPath"];
		if(![dictItemPath objectForKey:path]) {
			int tag = [[dictItemKind objectForKey:kind] intValue] + 1;
			NSTextFieldCell* itemCell = [[NSTextFieldCell alloc] initTextCell:path];
			[itemCell setTag:tag];
			
			// TODO Like above!
			[self insertRow:tag];
			
			[self putCell:itemCell atRow:tag column:0];
			
			[dictItemPath setObject:[NSNumber numberWithInt:tag] forKey:path];
		}
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
   [super release];
}
@end