//
//  NNFilterEngine.h
//  NNTagging
//
//  Created by Johannes Hoffart on 17.04.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NNTagging/NNQueue.h"
#import "NNTagging/NNTag.h"

#import "NNObjectFilter.h"

#include <unistd.h>

@protocol NNFilterEngineDelegate

- (void)filterEngineFilteredObjects:(NSArray*)objects;
- (void)filterEngineFinishedFiltering;

@end

@interface NNFilterEngine : NSOperation {
	BOOL				finished;
	
	id<NNFilterEngineDelegate> delegate;
		
	NSArray				*filters;
	NSMutableArray		*buffers;
	
	NSOperationQueue	*opQueue;
	
	NSMutableArray		*filteredObjects;
}

- (id)initWithFilterObjects:(NSArray*)objects 
					filters:(NSArray*)filters 
				   delegate:(id<NNFilterEngineDelegate>)aDelegate;

- (BOOL)hasFilters;

@end