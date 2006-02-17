//
//  PAActiveTags.m
//  punakea
//
//  Created by Johannes Hoffart on 17.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PASelectedTags.h"


@implementation PASelectedTags

-(id)init {
	self = [super init];
	if (self) {
		tags = [[NSMutableArray alloc] init];
	}
	return self;
}

-(void)dealloc {
	[tags release];
	[super dealloc];
}

//accessor
-(NSArray*)tags {
	return tags;
}

//---- BEGIN controller stuff ----

//add tags
-(void)addTagToTags:(NSString*)tag {
	[self addTagsToTags:[NSArray arrayWithObject:tag]];
}

-(void)addTagsToTags:(NSArray*)otherTags {
	int i = [otherTags count];
	while (i--) {
		if (![tags containsObject:[otherTags objectAtIndex:i]]) {
			[tags addObject:[otherTags objectAtIndex:i]];
		} else {
			NSLog(@"not adding tag @%, already present",[otherTags objectAtIndex:i]);
		}
	}
}

//remove/clear activetags
-(void)clearTags {
	[tags removeAllObjects];
}

-(void)removeTagFromTags:(NSString*)tag {
	[self removeTagsFromTags:[NSArray arrayWithObject:tag]];
}

-(void)removeTagsFromTags:(NSArray*)otherTags {
	int i = [otherTags count];
	while (i--) {
		[tags removeObject:[otherTags objectAtIndex:i]];
	}
}	
//---- END controller stuff ----

@end