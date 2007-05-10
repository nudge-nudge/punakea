//
//  NSTextViewAdditions.m
//  punakea
//
//  Created by Daniel on 10.05.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "NSTextFieldAdditions.h"


@implementation NSTextField (NSTextFieldAdditions)

/* Determines the minimum size of a textfield's content.
   Source: http://brockerhoff.net/bb/viewtopic.php?p=1982#1982
*/
- (NSSize)minSizeForContent
{
	NSRect frame = [self frame];
	NSRect newf = frame;
	NSTextView *editor = nil;
	
	if((editor = (NSTextView *)[self currentEditor])) {
		newf = [[editor layoutManager] usedRectForTextContainer:[editor textContainer]];
		newf.size.height += frame.size.height-[[self cell] drawingRectForBounds:frame].size.height;
	} else {
		newf.size.height = HUGE_VALF;
		newf.size = [[self cell] cellSizeForBounds:newf];
	}
	frame.size.height = newf.size.height;
	return frame.size;
}

@end
