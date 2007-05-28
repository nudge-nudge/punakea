//
//  PAContentTypeFilter.h
//  NNTagging
//
//  Created by Johannes Hoffart on 19.04.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NNObjectFilter.h"

#import "NNTagging/NNFile.h"
#import "NNTagging/NNSelectedTags.h"
#import "NNTagging/NNQuery.h"
#import "NNTagging/NNContentTypeTreeQueryFilter.h"

#import "PATagCache.h"

@interface PAContentTypeFilter : NNObjectFilter {
	NSString *contentType;
	
	NNSelectedTags *selectedTags;
	NNQuery *query;
	
	NSLock *filterLock;
	
	PATagCache *tagCache;
	
	BOOL shouldKeepRunning;
}

+ (PAContentTypeFilter*)filterWithContentType:(NSString*)type;

- (id)initWithContentType:(NSString*)type;
- (NSString*)contentType;

@end
