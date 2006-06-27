//
//  PABrowserController.m
//  punakea
//
//  Created by Johannes Hoffart on 27.06.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PABrowserController.h"

@implementation Controller (PABrowserController)

- (void)keyDown:(NSEvent*)event 
{
	NSLog(@"keyDown: %x", [[event characters] characterAtIndex:0]);
	unichar key = [[event charactersIgnoringModifiers] characterAtIndex:0];
	
	if (key == NSDeleteCharacter) 
	{
		if ([selectedTags count] > 0)
		{
			[selectedTags removeObjectFromSelectedTagsAtIndex:[selectedTags count]-1];
		}
	}
}

@end
