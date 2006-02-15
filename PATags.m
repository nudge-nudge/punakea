//
//  PATags.m
//  punakea
//
//  Created by Johannes Hoffart on 13.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PATags.h"
#import "PATaggerInterface.h"

@implementation PATags

-(id)init {
	self = [super init];
	if (self) {
		relatedTags = [[NSMutableArray alloc] init];
		activeTags = [[NSMutableArray alloc] init];
		//register with notificationcenter - listen for changes in the query results -- activeFiles is the query
        nf = [NSNotificationCenter defaultCenter];
        [nf addObserver:self selector:@selector(queryNote:) name:nil object:[[PATaggerInterface sharedInstance] query]];
		//TODO add system Tags ... how?
	}
	return self;
}

-(void)dealloc {
	[nf removeObserver:self];
	[activeTags release];
	[relatedTags release];
	[super dealloc];
}

//accessors
-(NSArray*)relatedTags {
	return relatedTags;
}

//bind active tag view to this -- TODO check if all the controller stuff can be done with a binding
-(NSArray*)activeTags {
	return activeTags;
}

//---- BEGIN controller stuff ----

//add tags
-(void)addTagToActiveTags:(NSString*)tag {
	[self addTagsToActiveTags:[NSArray arrayWithObject:tag]];
}

-(void)addTagsToActiveTags:(NSArray*)tags {
	int i = [tags count];
	while (i--) {
		if (![activeTags containsObject:[tags objectAtIndex:i]]) {
			[activeTags addObject:[tags objectAtIndex:i]];
		} else {
			NSLog(@"not adding tag @%, already present",[tags objectAtIndex:i]);
		}
	}
}

//remove/clear activetags
-(void)clearActiveTags {
	[activeTags removeAllObjects];
}

-(void)removeTagFromActiveTags:(NSString*)tag {
	[self removeTagsFromActiveTags:[NSArray arrayWithObject:tag]];
}

-(void)removeTagsFromActiveTags:(NSArray*)tags {
	int i = [tags count];
	while (i--) {
		[activeTags removeObject:[tags objectAtIndex:i]];
	}
}	
//---- END controller stuff ----
	
//act on query notifications -- relatedTags need to be kept in sync with files
-(void)queryNote:(NSNotification*)note {
	if ([[note name] isEqualToString:NSMetadataQueryDidUpdateNotification]) {
		//disable updates, parse files, continue -- TODO make more efficient, performance will SUCK
		[relatedTags removeAllObjects];
		NSMetadataQuery *query = [[PATaggerInterface sharedInstance] query];
		
		[query disableUpdates];
		
		int i = [query resultCount];
		while (i--) {
			//get keywords for result
			NSArray *keywords = [[PATaggerInterface sharedInstance] getTagsForFile:[query resultAtIndex:i]];
			
			int j = [keywords count];
			while (j--) {
				if (![relatedTags containsObject:[keywords objectAtIndex:j]]) {
					[relatedTags addObject:[keywords objectAtIndex:i]];
				}
			}
		}
		[query enableUpdates];
	}
}

@end