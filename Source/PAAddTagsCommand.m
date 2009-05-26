//
//  PAAddTagsCommand.m
//  punakea
//
//  Created by Daniel on 25.05.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PAAddTagsCommand.h"


@implementation PAAddTagsCommand

- (id)performDefaultImplementation
{
	// Get arguments
	NSDictionary *args = [self evaluatedArguments];
	
	// Get reference to file
	NNFile *file = [NNFile fileWithPath:(NSString *)[args objectForKey:@"filename"]];
	[file setShouldManageFiles:NO];
	
	// Add tags to file
	NSArray *tagNames = [args objectForKey:@""];
	
	NSArray *tags = [[NNTags sharedTags] tagsForNames:tagNames creationOptions:NNTagsCreationOptionFull];
	
	[file addTags:tags];
	
	return nil;
}

@end
