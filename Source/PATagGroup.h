//
//  PATagGroup.h
//  punakea
//
//  Created by Johannes Hoffart on 18.09.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NNTagging/NNTags.h"

@interface PATagGroup : NSObject {
	int maxSize;
	NSMutableArray *groupedTags;
	NSArray *sortDescriptors;
	
	NNTags *tags;
}

- (NSMutableArray*)groupedTags;
- (void)tagsHaveChanged;

- (void)setSortDescriptors:(NSArray*)someSortDescriptors;

@end
