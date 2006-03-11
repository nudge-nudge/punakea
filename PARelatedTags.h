//
//  PARelatedTags.h
//  punakea
//
//  Created by Johannes Hoffart on 11.03.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PATagger.h"
#import "PATag.h"

@interface PARelatedTags : NSObject {
	NSNotificationCenter *nf;
	NSMetadataQuery *query;
	NSMutableArray *tags;
	NSArrayController *controller;
}

- (id)initWithQuery:(NSMetadataQuery*)aQuery 
			   tags:(NSMutableArray*)mainTags 
		relatedTagsController:(NSArrayController*)aRelatedTagsController;

- (void)setQuery:(NSMetadataQuery*)aQuery;
- (void)setTags:(NSMutableArray*)mainTags;

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object 
                        change:(NSDictionary *)change
                       context:(void *)context;

- (void)resetRelatedTags;
- (void)updateRelatedTags;

@end

