//
//  PAThumbnailManager.m
//  punakea
//
//  Created by Daniel on 30.08.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAThumbnailManager.h"


int const CONCURRENT_IMAGE_LOADING_MAX = 3;


@implementation PAThumbnailManager

static PAThumbnailManager *sharedInstance = nil;

#pragma mark Init + Dealloc 
- (id)sharedInstanceInit
{
	self = [super init];
	if(self)
	{
		numberOfThumbsBeingProcessed = 0;
		thumbnails = [[NSMutableDictionary alloc] init];
		queue = [[NSMutableArray alloc] init];
		dummyImage = [NSImage imageNamed:@"tagit"];
	}
	return self;
}

- (void)dealloc
{
	if(queue) [queue release];
	if(thumbnails) [thumbnails release];
	if(dummyImage) [dummyImage release];
	[super dealloc];
}


#pragma mark Actions
- (NSImage *)thumbnailWithContentsOfFile:(NSString *)filename
{
	NSImage *thumbnail = [thumbnails objectForKey:filename];
	if(thumbnail)
	{
		// Thumbnail ready, return it
		return thumbnail;
	} else {
		// Add filename to queue						
		[queue addObject:filename];
		[thumbnails setObject:dummyImage forKey:filename];
		
		if(!timer)
		{
			timer = [NSTimer scheduledTimerWithTimeInterval:1.0
													 target:self
												   selector:@selector(processQueue)
												   userInfo:nil
													repeats:YES];
		}
		
		return dummyImage;
	}
}

- (void)processQueue
{
	NSLog(@"processing queue");
	
	while(numberOfThumbsBeingProcessed < CONCURRENT_IMAGE_LOADING_MAX &&
	      [queue count] > 0)
	{
		numberOfThumbsBeingProcessed++;
		
		NSString *filename = [queue objectAtIndex:0];
		[queue removeObjectAtIndex:0];
		
		[ThreadWorker workOn:self
				withSelector:@selector(generateThumbnailWithContentsOfFile:)
				  withObject:filename
			  didEndSelector:nil];
	}
	
	if(timer && [queue count] == 0)
	{
		[timer release];
		timer = nil;
	}
}

- (void)generateThumbnailWithContentsOfFile:(NSString *)filename
{
	NSImage *thumbnail = [[NSImage alloc] initWithContentsOfFile:filename];
	[thumbnail setSize:NSMakeSize(50,50)];
	
	[thumbnails setObject:thumbnail forKey:filename];
	
	numberOfThumbsBeingProcessed--;
	
	NSLog(@"finished %@", filename);
}


#pragma mark Singleton Stuff
+ (PAThumbnailManager *)sharedInstance
{
	@synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[self alloc] sharedInstanceInit];
        }
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
        }
    }
    return sharedInstance;
}

- (id)retain
{
    return self;
}

- (unsigned)retainCount
{
    return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

@end
