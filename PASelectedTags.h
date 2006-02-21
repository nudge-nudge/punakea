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
}

- (NSEnumerator*)objectEnumerator;

//controller stuff
- (void)addTagToTags:(NSString*)tag;
- (void)addTagsToTags:(NSArray*)tags;
- (void)clearTags;
- (void)removeTagFromTags:(NSString*)tag;
- (void)removeTagsFromTags:(NSArray*)tags;

@end