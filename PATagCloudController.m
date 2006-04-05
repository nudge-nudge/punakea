//
//  PATagCloudController.m
//  punakea
//
//  Created by Johannes Hoffart on 29.03.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PATagCloudController.h"


@implementation Controller (PATagCloudController)

- (IBAction)tagButtonClicked:(id)sender
{
	PATag *tag = [sender fileTag];
	[selectedTagsController addObject:tag];
	[tag incrementClickCount];
}

- (NSDictionary*)viewAttributesForTag:(PATag*)tag
{
	NSMutableDictionary *attribs = [NSMutableDictionary dictionary];
	
	NSColor *c = [NSColor colorWithDeviceRed:0.0 green:0.0 blue:128.0 alpha:1.0];
	//externalize sizes
	int size = 30 * [tag relativeRatingToTag:[self currentBestTag]];
	if (size < 10)
		size = 10;
	
	NSFont *fnt = [NSFont fontWithName:@"Geneva" size:size];
	
	[attribs setObject:c forKey:NSForegroundColorAttributeName];
	[attribs setObject:fnt forKey:NSFontAttributeName];
	
	return attribs;
}

@end
