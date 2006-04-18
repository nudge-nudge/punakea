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
		[self setCellClass:[NSTextFieldCell class]];
		[self renewRows:1 columns:3];
		[self setIntercellSpacing:NSMakeSize(14,0)];
		[self setMode:NSHighlightModeMatrix];
		[self setTarget:self];
		[self setAutosizesCells:YES];
    }
    return self;
}

- (void)dealloc
{
	if(item) [item release];
	[super dealloc];
}


#pragma mark Accessors
- (PAResultsMultiItem *)item
{
	return item;
}

- (void)setItem:(PAResultsMultiItem *)anItem
{
	item = [anItem retain];
}

@end
