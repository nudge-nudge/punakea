//
//  PAResultsMultiItemCell.m
//  punakea
//
//  Created by Daniel on 15.04.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAResultsMultiItemCell.h"


@implementation PAResultsMultiItemCell

#pragma mark Init + Dealloc
- (id)initTextCell:(NSString *)aText
{
	self = [super initTextCell:aText];
	//if (self) {}	
	return self;
}

- (void)dealloc
{
	if(item) [item release];
	if(matrix) [matrix release];
	[super dealloc];
}


#pragma mark Drawing
- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{	
	/*NSEnumerator *enumerator = [[controlView subviews] objectEnumerator];
	id anObject;
	
	while(anObject = [enumerator nextObject])
	{
		if([[anObject class] isEqualTo:[PAResultsMultiItemMatrix class]])
		{
			PAResultsMultiItem *thisItem = [(PAResultsMultiItemMatrix *)anObject item];
			if([item isEqualTo:thisItem])
				matrix = anObject;
				NSLog(@"exists");
		}
	}

	if([matrix superview] != controlView)
	{	
		matrix = [[PAResultsMultiItemMatrix alloc] initWithFrame:cellFrame];
		[matrix setItem:item];		
		[[self controlView] addSubview:matrix];
		NSLog(@"added");
	}
	else
	{
		[matrix setFrame:cellFrame];
	}*/
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
