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

- (void)initWithMetadataQuery:(NSMetadataQuery*)aQuery {
	query = aQuery;
	NSNotificationCenter *nf = [NSNotificationCenter defaultCenter];
    [nf addObserver:self selector:@selector(queryNote:) name:nil object:query];
	
	[self addSampleCells];
}

- (void)addSampleCells {
	PASpotlightTypeCell* typeCell = [[PASpotlightTypeCell alloc] initTextCell:@"hallo"];
	[self insertRow:1];
	[self insertColumn:1];
	[self putCell:typeCell atRow:0 column:0];
}

- (void)updateView {
	
}

- (void)queryNote:(NSNotification *)note {
	NSLog(@"fileMatrix: note received");
	
	if ([[note name] isEqualToString:@"NSMetadataQueryGatheringProgressNotification"]) {
		[self updateView];
	}
}
@end
