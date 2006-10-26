//
//  PATagGroup.h
//  punakea
//
//  Created by Johannes Hoffart on 18.09.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PATagger.h"
#import "PATags.h"


@interface PATagGroup : NSObject {
	int maxSize;
	NSMutableArray *groupedTags;
	NSArray *sortDescriptors;
	
	PATags *tags;
}

- (NSMutableArray*)groupedTags;
- (void)tagsHaveChanged;

- (void)setSortDescriptors:(NSArray*)someSortDescriptors;

@end
