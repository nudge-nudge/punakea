//
//  PAFileMatrix.m
//  punakea
//
//  Created by Daniel on 08.03.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAFileMatrix.h"
#import "PASpotlightTypeCell.h"


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
	[self renewRows:10 columns:1];
	[self setCellSize:NSMakeSize(200,30)];
	
	dictKind = [[NSMutableDictionary alloc] init];	
}

- (void)setQuery:(NSMetadataQuery*)aQuery
{
	query = aQuery;
	NSNotificationCenter *nf = [NSNotificationCenter defaultCenter];
    [nf addObserver:self selector:@selector(queryNote:) name:nil object:query];
}

- (void)updateView {
	int i;
	
	// Add rows für kMDItemKind
	for (i = 0; i < [query resultCount]; i++)
	{
		NSMetadataItem* item = [query resultAtIndex:i];
		NSString* kind = [item valueForAttribute:@"kMDItemKind"];
		if (![dictKind valueForKey:kind])
		{
			int tag = [dictKind count];
			PASpotlightTypeCell* kindCell = [[PASpotlightTypeCell alloc] initTextCell:kind];
			[kindCell setTag:tag];
			[self putCell:kindCell atRow:tag column:0];
			[dictKind setValue:@"ja" forKey:kind];
		}
	}
}

- (void)queryNote:(NSNotification *)note {
	NSLog(@"fileMatrix: note received");
	
	if ([[note name] isEqualToString:NSMetadataQueryGatheringProgressNotification] ||
		[[note name] isEqualToString:NSMetadataQueryDidUpdateNotification] ||
		[[note name] isEqualToString:NSMetadataQueryDidFinishGatheringNotification]) {
		[self updateView];
	}
}

- (void)dealloc
{
   if(dictKind)
      [dictKind release];
   [super release];
}
@end