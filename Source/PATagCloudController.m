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
	return [self viewAttributesForTag:tag hovered:NO];
}

- (NSDictionary*)viewAttributesForTag:(PATag*)tag hovered:(BOOL)isHovered
{
	NSMutableDictionary *attribs = [NSMutableDictionary dictionary];
	
	//externalize sizes
	float tagRating = [tag relativeRatingToTag:[self currentBestTag]];
	int size = 25 * tagRating;
	if (size < 12)
		size = 12;
	
	NSFont *fnt = [NSFont fontWithName:@"Geneva" size:size];
	
	NSColor *fgc;
	
	if (isHovered)
	{
		fgc = [NSColor whiteColor];
	}
	else
	{
		fgc = [NSColor blueColor];
	}
	
	[attribs setObject:fgc forKey:NSForegroundColorAttributeName];
	[attribs setObject:fnt forKey:NSFontAttributeName];
	
	return attribs;
}

@end
