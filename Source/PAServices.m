//
//  PAServices.m
//  punakea
//
//  Created by Johannes Hoffart on 28.05.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PAServices.h"


@implementation PAServices

#pragma mark init
- (id)init
{
	if (self = [super init])
	{
		dropManager = [PADropManager sharedInstance];
	}
	return self;
}

#pragma mark services
- (void)tagFiles:(NSPasteboard *)pboard
		userData:(NSString *)userData
		   error:(NSString **)error
{
    NSDragOperation op = [dropManager performedDragOperation:pboard];
	
	NSLog(@"%@",[pboard types]);
	
	if (op == NSDragOperationNone)
	{
		*error = NSLocalizedStringFromTable(@"SERVICE_NOT_WORKING", @"FileManager", nil);
		return;
	}
	else
	{
		NSArray *files = [dropManager handleDrop:pboard];
		[[[NSApplication sharedApplication] delegate] showTaggerForObjects:files];
	}
}

- (void)openTagger:(NSPasteboard *)pboard
		userData:(NSString *)userData
		   error:(NSString **)error
{
	[[[NSApplication sharedApplication] delegate] showTagger:self];
}

@end
