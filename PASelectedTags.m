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

//needs to be called whenever the active tags have been changed
-(void)selectedTagsHaveChanged {
	//stop an active query
	if ([query isStarted]) {
		[query stopQuery];
	}
	
	//start the query for files first -- LoD
	NSMutableString *queryString = [[tags objectAtIndex:0] query];
	
	int j = [tags count];
	int i = j;
	while (i--) {
		NSString *anotherTagQuery = [NSString stringWithFormat:@" && %@",[[tags objectAtIndex:j-i] query]];
		[queryString appendString:anotherTagQuery];
	}
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:queryString];
	[query setPredicate:predicate];
	[query startQuery];
	
	/* now it is up to PATags to listen for changes in the result of the query to adjust the related tags accordingly
		view must bind to query.result and also register with notification to be informed about updates */
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