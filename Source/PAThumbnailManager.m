//
//  PAThumbnailManager.m
//  punakea
//
//  Created by Daniel on 30.08.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAThumbnailManager.h"


int const CONCURRENT_IMAGE_LOADING_MAX = 5;


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
- (NSImage *)thumbnailWithContentsOfFile:(NSString *)filename inView:(NSView *)aView frame:(NSRect)aFrame
{
	NSImage *thumbnail = [thumbnails objectForKey:filename];
	if(thumbnail)
	{
		// Thumbnail ready, return it
		return thumbnail;
	} else {
		// Add filename to queue						
		PAThumbnailItem *item = [[PAThumbnailItem alloc] initForFile:filename inView:aView frame:aFrame];		
		[queue addObject:item];
		[thumbnails setObject:dummyImage forKey:filename];
		
		if(!timer)
		{
			timer = [NSTimer scheduledTimerWithTimeInterval:0.2
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
	//NSLog(@"processing queue");
	
	while(numberOfThumbsBeingProcessed < CONCURRENT_IMAGE_LOADING_MAX &&
	      [queue count] > 0)
	{
		numberOfThumbsBeingProcessed++;
		
		PAThumbnailItem *item = [queue objectAtIndex:0];		 
		[queue removeObjectAtIndex:0];
		
		[ThreadWorker workOn:self
				withSelector:@selector(generateThumbnailFromFile:)
				  withObject:item
			  didEndSelector:nil];
	}
	
	if(timer && [queue count] == 0)
	{
		[timer release];
		timer = nil;
	}
}

- (void)generateThumbnailFromFile:(PAThumbnailItem *)thumbnailItem
{
	NSString *filename = [thumbnailItem filename];

	NSImage *thumbnail = [self scaledImageFromFile:filename maxwidth:60 maxheight:60 quality:0.5];
	if([[thumbnailItem view] isFlipped]) [thumbnail setFlipped:YES];
	
	[thumbnails setObject:thumbnail forKey:filename];
	
	numberOfThumbsBeingProcessed--;
	
	// Refresh item's view
	NSView *view = [thumbnailItem view];
	NSRect frame = [thumbnailItem frame];
	[view setNeedsDisplayInRect:frame];
	
	[thumbnailItem release];
	
	//NSLog(@"finished %@", filename);
}

-(NSImage *)scaledImageFromFile:(NSString *)source 
		               maxwidth:(int)width 
		              maxheight:(int)height 
		                quality:(float)quality
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSBitmapImageRep *rep = nil;
    NSBitmapImageRep *output = nil;
    NSImage *scratch = nil;
    int w,h,nw,nh;
    NSData *bitmapData;
    
    rep = [NSBitmapImageRep imageRepWithContentsOfFile:source];
    
    // could not open file
    if (!rep)
    {
		NSLog(@"Could not load '%@'", source);
		[pool release];
		return nil;
    };
    
    // validation
    if (quality<=0.0)
    {
	quality = 0.85;
    };
    
    if (quality>1.0)
    {
	quality = 1.00;
    };
    
    // source image size
    w = nw = [rep pixelsWide];
    h = nh = [rep pixelsHigh];
    
    if (w>width || h>height)
    {
	float wr, hr;
	
	// ratios
	wr = w/(float)width;
	hr = h/(float)height;
	
	
	if (wr>hr) // landscape
	{
	    nw = width;
	    nh = h/wr;
	}
	else // portrait
	{
	    nh = height;
	    nw = w/hr;
	};
	
    };
    
    // image to render into
    scratch = [[[NSImage alloc] initWithSize:NSMakeSize(nw, nh)] autorelease];
    
    // could not create image
    if (!scratch)
	{
		NSLog(@"Could not render image");
		[pool release];
		return nil;
    };
    
    // draw into image, to scale it
    [scratch lockFocus];
	[NSGraphicsContext saveGraphicsState];
	
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationLow];
    
	[rep drawInRect:NSMakeRect(0.0, 0.0, nw, nh)];
    output = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0,0,nw,nh)];
	
	[NSGraphicsContext restoreGraphicsState];
    [scratch unlockFocus];
    
    // could not get result
    if (!output)
    {
		NSLog(@"Could not scale image");
		[pool release];
		return nil;
    };
    
    // save as JPEG - for Alternative 1
    /*NSDictionary *properties =
        [NSDictionary dictionaryWithObjectsAndKeys:
	    [NSNumber numberWithFloat:quality],
	    NSImageCompressionFactor, NULL];    
    
    bitmapData = [output representationUsingType:NSJPEGFileType
				      properties:properties];
    
    // could not get result
    if (!bitmapData)
    {
		NSLog(@"Could not convert to JPEG");
		[pool release];
		return nil;
    };*/
    
	// Output to file
    //BOOL ret = [bitmapData writeToFile:dest atomically:YES];
	
	// Alternative 1
	//NSImage *image = [[NSImage alloc] initWithData:bitmapData];
	
	// Alternative 2
	NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(nw,nh)];
	[image addRepresentation:output];	
	
	[output release];
	[pool release];
	
	return image;
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
