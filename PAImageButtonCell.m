//
//  PAImageButtonCell.m
//  punakea
//
//  Created by Daniel on 21.03.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAImageButtonCell.h"


@implementation PAImageButtonCell

- (id)initImageCell:(NSImage *)anImage
{	
	images = [[NSMutableDictionary alloc] init];
	return [super initImageCell:anImage];
}

- (void)setImage:(NSImage *)image forState:(PAImageButtonState)state
{
	[images setObject:image forKey:(id)state];
}

- (void)dealloc
{
	if(images) { [images release]; }
	[super dealloc];
}

@end
