//
//  PADropManager.m
//  punakea
//
//  Created by Johannes Hoffart on 08.09.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PADropManager.h"

@interface PADropManager (PrivateAPI)



@end

@implementation PADropManager

//this is where the sharedInstance is held
static PADropManager *sharedInstance = nil;

#pragma mark init
//constructor - only called by sharedInstance
- (id)sharedInstanceInit {
	if (self = [super init])
	{
		dropHandlers = [[NSMutableArray alloc] init];
			
		// currently all the dropHandlers have to be created ... 
		PAFilenamesDropHandler *filenamesDropHandler = [[PAFilenamesDropHandler alloc] init];
		[self registerDropHandler:filenamesDropHandler];
		[filenamesDropHandler release];
			
		PABookmarkDictionaryListDropHandler *bookmarkDictionaryListDropHandler = [[PABookmarkDictionaryListDropHandler alloc] init];
		[self registerDropHandler:bookmarkDictionaryListDropHandler];
		[bookmarkDictionaryListDropHandler release];
	}
	return self;
}

- (void)dealloc
{
	[dropHandlers release];
	[super dealloc];
}

- (void)registerDropHandler:(PADropHandler*)handler
{
	[dropHandlers addObject:handler];
}
	
- (void)removeDropHandler:(PADropHandler*)handler
{
	[dropHandlers removeObject:handler];
}

- (NSArray*)handledPboardTypes
{
	NSMutableArray *handledTypes = [NSMutableArray array];
	
	NSEnumerator *e = [dropHandlers objectEnumerator];
	PADropHandler *dropHandler;
	
	while (dropHandler = [e nextObject])
	{
		[handledTypes addObject:[dropHandler pboardType]];
	}
	
	return handledTypes;
}

- (NSArray*)handleDrop:(NSPasteboard*)pasteboard
{
	NSArray *result = nil;
	
	NSEnumerator *e = [dropHandlers objectEnumerator];
	PADropHandler *dropHandler;
	
	// all dropHandlers are queried if they handle the needed pboardType
	while (dropHandler = [e nextObject])
	{
		if ([dropHandler willHandleDrop:pasteboard])
		{
			result = [dropHandler handleDrop:pasteboard];
		}
	}

	return result;
}

- (NSDragOperation)performedDragOperation:(NSPasteboard*)pasteboard
{
	NSDragOperation op = NSDragOperationNone;
	
	NSEnumerator *e = [dropHandlers objectEnumerator];
	PADropHandler *dropHandler;
	
	while (dropHandler = [e nextObject])
	{
		if ([dropHandler willHandleDrop:pasteboard])
			op = [dropHandler performedDragOperation:pasteboard];
	}
	
	return op;
}

#pragma mark singleton stuff
+ (PADropManager*)sharedInstance {
	@synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[self alloc] sharedInstanceInit];
        }
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
        }
    }
    return sharedInstance;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

@end
