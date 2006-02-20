//
//  PAActiveTags.h
//  punakea
//
//  Created by Johannes Hoffart on 17.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PASelectedTags : NSObject {
	NSMutableArray *tags;
	//only that it builds TODO
	NSMetadataQuery *query;
}

//collection type might change, don't depend on it too heavily
- (NSArray*)tags;

//update method - TODO notification?
- (void)selectedTagsHaveChanged;

//controller stuff
- (void)addTagToTags:(NSString*)tag;
- (void)addTagsToTags:(NSArray*)tags;
- (void)clearTags;
- (void)removeTagFromTags:(NSString*)tag;
- (void)removeTagsFromTags:(NSArray*)tags;

@end