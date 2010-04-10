//
//  URLHandlerCategory.m
//  punakea
//
//  Created by hoffart on 01.04.10.
//  Copyright 2010 nudge:nudge. All rights reserved.
//

#import "URLHandlerCategory.h"


@implementation Core (URLHandlerCategory)

#pragma mark URL handling
- (void)getUrl:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
	NSString *url = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
	NSArray *tags = [self tagsForPunakeaURL:url];
	
	if ([tags count] > 0)
	{
		[self searchForTags:tags];
	}
}

- (NSArray*)tagsForPunakeaURL:(NSString*)tagURL
{
	NSURL *url = [NSURL URLWithString:tagURL];
	
	NSString *tagString = [url path];
		
	NSArray *tagNames = [tagString componentsSeparatedByString:@"/"];
	
	NSArray *tags = [tagging tagsForTagnames:tagNames];
	
	return tags;
}

@end
