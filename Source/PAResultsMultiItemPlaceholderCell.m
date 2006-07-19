//
//  PAResultsMultiItemPlaceholderCell.m
//  punakea
//
//  Created by Daniel on 15.07.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAResultsMultiItemPlaceholderCell.h"


@implementation PAResultsMultiItemPlaceholderCell

#pragma mark Drawing
- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	// Do nothing
}

- (void)highlight:(BOOL)flag withFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	// Do nothing
}

#pragma mark Accessors
- (NSString *)value
{
	return @"";
}

#pragma mark Class methods
+ (NSSize)cellSize
{
	return NSMakeSize(1, 1);
}

+ (NSSize)intercellSpacing
{
	return NSMakeSize(1, 1);
}

@end
