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
	NSTextFieldCell* textCell1 = [[NSTextFieldCell alloc] initTextCell:@"huhu1"];
	NSTextFieldCell* textCell2 = [[NSTextFieldCell alloc] initTextCell:@"huhu2"];
	NSTextFieldCell* textCell3 = [[NSTextFieldCell alloc] initTextCell:@"huhu3"];
	
	[self insertRow:0];
	[self putCell:textCell1 atRow:0 column:0];
	[self insertRow:1];
	[self putCell:textCell2 atRow:1 column:0];
	[self insertRow:2];
	[self putCell:textCell3 atRow:2 column:0];
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
