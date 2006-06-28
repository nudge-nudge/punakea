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
	//TODO exclude everything with modifier keys pressed!
	// get the pressed key
	NSLog(@"keyDown: %x", [[event characters] characterAtIndex:0]);
	unichar key = [[event charactersIgnoringModifiers] characterAtIndex:0];
	
	// create character set for testing
	NSCharacterSet *charSet = [NSCharacterSet alphanumericCharacterSet];
	
	if (key == NSDeleteCharacter) 
	{
		// if buffer has any content (i.e. user is using type-ahead-find), delete last char
		if ([buffer length] > 0)
		{
			NSRange range = NSMakeRange([buffer length] - 1,1);
			[buffer deleteCharactersInRange:range];
		}
		else if ([selectedTags count] > 0)
		// else delete the last selected tag
		{
			[selectedTags removeObjectFromSelectedTagsAtIndex:[selectedTags count]-1];
		}
	} else if ([charSet characterIsMember:key]) {
		// TODO check if it is ok to append event instead of key
		[buffer appendString:[event charactersIgnoringModifiers]];
	}
	
	// if buffer has any content, display tags with corresponding prefix
	// else display all tags
	if ([buffer length] > 0)
	{
		[typeAheadFind setPrefix:buffer];
		[self setVisibleTags:[typeAheadFind matchingTags]];
	}
	else
	{
		// only set if not already set
		if (!(visibleTags == [tags tags]))
		{
			[self setVisibleTags:[tags tags]];
			NSLog(@"called");
		}
	}
		
	NSLog(@"%@",buffer);
}

@end
