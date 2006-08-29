//
//  PASidebarTableColumn.m
//  punakea
//
//  Created by Johannes Hoffart on 29.08.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PASidebarTableColumn.h"


@implementation PASidebarTableColumn

- (void)awakeFromNib
{
	dataCell = [[PAButtonCell alloc] init];
	[dataCell setBezelStyle:PATagBezelStyle];
	
	//[self setDataCell:dataCell];
}

- (void)dealloc
{
	[dataCell release];
	[super dealloc];
}

@end
