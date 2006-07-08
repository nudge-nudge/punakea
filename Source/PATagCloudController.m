//
//  PATagCloudController.m
//  punakea
//
//  Created by Johannes Hoffart on 29.03.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PATagCloudController.h"

@implementation BrowserViewController (PATagCloudController)

- (IBAction)tagButtonClicked:(id)sender
{
	PATag *tag = [sender fileTag];
	[selectedTags addTag:tag];
	[tag incrementClickCount];
}

- (NSDictionary*)viewAttributesForTag:(PATag*)tag
{
	NSMutableDictionary *attribs = [NSMutableDictionary dictionary];
	
	//externalize sizes
	float tagRating = [tag relativeRatingToTag:[self currentBestTag]];
	int size = 30 * tagRating;
	if (size < 10)
		size = 10;
	
	NSFont *fnt = [NSFont fontWithName:@"Geneva" size:size];
	NSColor *fgc = [NSColor colorWithDeviceRed:0.0 green:0.0 blue:128.0 alpha:1.0];
	
	[attribs setObject:fgc forKey:NSForegroundColorAttributeName];
	[attribs setObject:fnt forKey:NSFontAttributeName];
	
	return attribs;
}

@end
