//
//  TaggerInterface.m
//  punakea
//
//  Created by Johannes Hoffart on 05.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <CoreServices/CoreServices.h>
#import "PATaggerInterface.h"
#import "Matador.h"

//private stuff
@interface PATaggerInterface (PrivateAPI)
-(void)writeTagsToFile:(NSArray*)tags filePath:(NSString*)path;
-(NSArray*)getTagsForFile:(NSString*)path;

@end

@implementation PATaggerInterface

//this is where the sharedInstance is held
static PATaggerInterface *sharedInstance = nil;

//constructor - TODO synchronize
-(id)sharedInstanceInit {
	self = [super init];
	//initalize the query
	query = [[NSMetadataQuery alloc] init];
	//initalize tag model
	tagModel = [[PATags alloc] init];
	//set the tag prefix
	[tagPrefix initWithString:@"tag:"];
	return self;
}

//accessors
-(NSArray*)relatedTags {
	return [tagModel relatedTags];
}

-(NSArray*)activeTags {
	return [tagModel activeTags];
}

//needed for bindings - bind to query.results
-(NSMetadataQuery*)query {
	return query;
}

//write tags
-(void)addTagToFile:(NSString*)tag filePath:(NSString*)path {
	[self addTagsToFile:[NSArray arrayWithObject:tag] filePath:path];
}

//adds the specified tags, doesn't overwrite
-(void)addTagsToFile:(NSArray*)tags filePath:(NSString*)path {
	NSMutableArray *resultTags = [NSMutableArray arrayWithArray:tags];
	
	//existing tags must be kept - only if there are any
	if ([[self getTagsForFile:path] count] > 0) {
		NSArray *currentTags = [self getTagsForFile:path];

		/* check if the file had tags which are not in the
		   tags to be added - need to keep them */
		NSEnumerator *e = [currentTags objectEnumerator];
		id tag;
		
		while ( (tag = [e nextObject]) ) {
			if (![resultTags containsObject:tag]) {
				[resultTags addObject:tag];
			}
		}
	}
	
	//write the tags to kMDItemKeywords - new and existing ones
	[self writeTagsToFile:resultTags filePath:path];
}

//sets the tags, overwrites current ones
-(void)writeTagsToFile:(NSArray*)tags filePath:(NSString*)path {
	[[Matador sharedInstance] setAttributeForFileAtPath:path name:@"kMDItemKeywords" value:tags];
}

//read tags - TODO there could be a lot of mem-leaks in here ... check if file exists!!
-(NSArray*)getTagsForFile:(NSString*)path {
	//carbon api ... can be treated as cocoa objects - TODO check warnings
	MDItemRef *item = MDItemCreate(NULL,path);
	CFTypeRef *keywords = MDItemCopyAttribute(item,@"kMDItemKeywords");
	return [keywords autorelease];
}

//needs to be called whenever the active tags have been changed
-(void)activeTagsHaveChanged {
	//stop an active query
	if ([query isStarted]) {
		[query stopQuery];
	}
	
	//start the query for files first	
	NSMutableString *queryString = [NSMutableString stringWithFormat:@"kMDItemKeywords == '%@:%@'",tagPrefix,[[tagModel activeTags] lastObject]];
	
	int i = [[tagModel activeTags] count]-1;
	while (i--) {
		NSString *anotherTagQuery = [NSMutableString stringWithFormat:@" && kMDItemKeywords == '%@:%@'",tagPrefix,[[tagModel activeTags] objectAtIndex:i]];
		[queryString appendString:anotherTagQuery];
	}
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:queryString];
	[query setPredicate:predicate];
	[query startQuery];
	
	/* now it is up to PATags to listen for changes in the result of the query to adjust the related tags accordingly
		view must bind to query.result and also register with notification to be informed about updates */
}

//TODO might never be called - check if needed
-(void)dealloc {
	[query dealloc];
	[tagModel dealloc];
	[super dealloc];
}

//---- BEGIN singleton stuff ----
+(PATaggerInterface*)sharedInstance {
	@synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[self alloc] sharedInstanceInit];
        }
    }
    return sharedInstance;
}

+(id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
        }
    }
    return sharedInstance;
}

-(id)retain {
    return self;
}

-(unsigned)retainCount {
    return UINT_MAX;  //denotes an object that cannot be released
}

-(void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}
//---- END singleton stuff ----

@end