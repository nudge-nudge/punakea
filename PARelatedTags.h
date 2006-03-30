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
	NSArrayController *controller;
}

- (id)initWithQuery:(NSMetadataQuery*)aQuery 
		relatedTagsController:(NSArrayController*)aRelatedTagsController;

- (void)setQuery:(NSMetadataQuery*)aQuery;

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object 
                        change:(NSDictionary *)change
                       context:(void *)context;

@end

