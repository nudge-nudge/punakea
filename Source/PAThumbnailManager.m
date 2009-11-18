//
//  PAThumbnailManager.m
//  punakea
//
//  Created by Daniel on 30.08.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "PAThumbnailManager.h"


NSInteger const CONCURRENT_IMAGE_LOADING_MAX = 5;
NSInteger const NUMBER_OF_CACHED_ITEMS_MAX = 300;
useconds_t const FIRST_ITEM_NOTIFICATION_DELAY = 200000;		// 0.2 sec

NSString * const PAThumbnailManagerDidFinishGeneratingItemNotification = @"PAThumbnailManagerDidFinishGeneratingItemNotification";


@interface PAThumbnailManager (PrivateAPI)

- (NSImage *)thumbnailFromFileNew:(NSString *)filename maxBounds:(NSSize)maxBounds;
- (NSImage *)scaledImageFromFile:(NSString *)source 
		               maxBounds:(NSSize)maxBounds
		                quality:(CGFloat)quality;

@end


@implementation PAThumbnailManager

static PAThumbnailManager *sharedInstance = nil;

#pragma mark Init + Dealloc 
- (id)sharedInstanceInit
{
	self = [super init];
	if(self)
	{
		icons = [[NSMutableDictionary alloc] init];
		thumbnails = [[NSMutableDictionary alloc] init];
		queue = [[NNQueue alloc] init];
		stack = [[NSMutableArray alloc] init];
		
		dummyImageThumbnail = [NSImage imageNamed:@"dummyThumbLarge"];
		[dummyImageThumbnail setFlipped:YES];
		dummyImageIcon = [NSImage imageNamed:@"dummyThumbSmall"];
		[dummyImageIcon setFlipped:YES];
		
		[NSApplication detachDrawingThread:@selector(processQueue)
								  toTarget:self
								withObject:nil];
		
		processLock = [[NSLock alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[processLock release];
	[stack release];
	[queue release];
	[thumbnails release];
	[icons release];
	[dummyImageThumbnail release];
	[dummyImageIcon release];
	
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
		[thumbnails setObject:dummyImageThumbnail forKey:filename];
		
		PAThumbnailItem *item = [[PAThumbnailItem alloc] initForFile:filename inView:aView frame:aFrame type:PAItemTypeThumbnail];		
		[queue enqueue:item];
		[item release];
		
		return dummyImageThumbnail;
	}
}

- (NSImage *)iconForFile:(NSString *)filename inView:(NSView *)aView frame:(NSRect)aFrame
{
	// Get extension
	/*FSRef ref;
	LSItemInfoRecord outInfo;
	
	NSURL *url = [[NSURL alloc] initFileURLWithPath:filename];
	CFURLGetFSRef((CFURLRef)url, &ref);
	LSCopyItemInfoForRef(&ref, kLSRequestExtension, &outInfo);
	
	NSString *extension = [[outInfo.extension copy] autorelease];
	
	CFRelease(outInfo.extension);
	[url release];*/

	// Get icon
	[processLock lock];
	NSImage *icon = [icons objectForKey:filename];
	[processLock unlock];
	
	if(icon)
	{
		return icon;
	} else {		
		// Add filename to queue
		[processLock lock];
		[icons setObject:dummyImageIcon forKey:filename];
		[processLock unlock];
		
		PAThumbnailItem *item = [[PAThumbnailItem alloc] initForFile:filename inView:aView frame:aFrame type:PAItemTypeIcon];		
		
		// Processing icons is blazingly fast. We need to delay the first item of the queue to
		// give the control view enough time for its own stuff. 
		if([queue count] == 0)
			delayNextNotification = YES;
		
		[queue enqueue:item];
		[item release];
		
		return dummyImageIcon;
	}
}

- (void)processQueue
{
	while(true)
	{	
		PAThumbnailItem *item = [queue dequeue];
		
		if([item type] == PAItemTypeThumbnail)
		{
			[self generateThumbnailFromFile:item];
		} else {
			[self generateIconForFile:item];
		}
		
		// queue doesn't autorelease stuff
		[item release];
	
		// If number of cached images exceeds limit, remove first item of stack
		[processLock lock];
		if([stack count] > NUMBER_OF_CACHED_ITEMS_MAX)
		{
			NSString *filename = [stack objectAtIndex:0];
			
			[thumbnails removeObjectForKey:filename];
			[icons removeObjectForKey:filename];
			[stack removeObjectAtIndex:0];
		}
		[processLock unlock];
	}
}

- (void)generateThumbnailFromFile:(PAThumbnailItem *)thumbnailItem
{
	NSString *filename = [thumbnailItem filename];

	NSImage *thumbnail = [self thumbnailFromFileNew:filename maxBounds:NSMakeSize(76,75)];
	//if([[thumbnailItem view] isFlipped]) [thumbnail setFlipped:YES];
	
	[processLock lock];

	[thumbnails removeObjectForKey:filename];
	[thumbnails setObject:thumbnail forKey:filename];
	[stack addObject:filename];
	
	[processLock unlock];
	
	// Post notification
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:PAThumbnailManagerDidFinishGeneratingItemNotification object:thumbnailItem];
}

- (void)generateIconForFile:(PAThumbnailItem *)thumbnailItem
{
	NSString *filename = [thumbnailItem filename];

	NSImage *img = [[NSWorkspace sharedWorkspace] iconForFile:filename];
	
	[processLock lock];

	[icons removeObjectForKey:filename];
	[icons setObject:img forKey:filename];
	[stack addObject:filename];
	
	[processLock unlock];
	
	// Post notification
	if(delayNextNotification)
	{
		delayNextNotification = NO;
		usleep(FIRST_ITEM_NOTIFICATION_DELAY);
	}
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

	[nc postNotificationName:PAThumbnailManagerDidFinishGeneratingItemNotification object:thumbnailItem];
}

- (NSImage *)thumbnailFromFileNew:(NSString *)filename maxBounds:(NSSize)maxBounds
{
	NSDictionary        *imageOptions = [NSDictionary 
				dictionaryWithObjectsAndKeys:
                           (id)kCFBooleanTrue, (id)kCGImageSourceShouldCache,
                           (id)kCFBooleanTrue, (id)kCGImageSourceShouldAllowFloat,
                           nil];
						   
	NSURL                *urlOfImage = [[NSURL alloc] initFileURLWithPath:filename];
	
	CGImageSourceRef imageSourceRef = CGImageSourceCreateWithURL((CFURLRef)urlOfImage, NULL);
	[urlOfImage release];

	// First, try getting thumbnail image
	CGImageRef image = CGImageSourceCreateThumbnailAtIndex(imageSourceRef,
		0,(CFDictionaryRef)imageOptions);
	
	// If this doesn't work, get ImageAtIndex
	if(image == NULL)
	{
		// This is the way it works
		//image = CGImageSourceCreateImageAtIndex(imageSourceRef,
		//	0,imageOptions);
		
		// This way of loading the whole file uses much less memory
		NSImage *img = [self scaledImageFromFile:filename maxBounds:maxBounds quality:0.8];
		
		CFRelease(imageSourceRef);
		
		return img;			
	} else {				
		// image size
		NSInteger w, nw, h, nh;
		w = nw = CGImageGetWidth(image);
		h = nh = CGImageGetHeight(image);
		
		if (w > maxBounds.width || h > maxBounds.height)
		{
			CGFloat wr, hr;
			
			// ratios
			wr = w / maxBounds.width;
			hr = h / maxBounds.height;
			
			
			if (wr>hr) // landscape
			{
				nw = maxBounds.width;
				nh = h/wr;
			}
			else // portrait
			{
				nh = maxBounds.height;
				nw = w/hr;
			};		
		};
		
		NSImage *img = [[NSImage alloc] initWithSize:NSMakeSize(nw,nh)];
		[img setFlipped:YES];
		
		CGRect CGImgRect = CGRectMake(0,0,nw,nh);
		
		[img lockFocus];	
		[NSGraphicsContext saveGraphicsState];
		
		CGContextRef imageContext = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
		CGContextDrawImage(imageContext, CGImgRect, image);
		
		[NSGraphicsContext restoreGraphicsState];	
		[img unlockFocus];
		
		CGImageRelease(image);
		CFRelease(imageSourceRef);
		
		return [img autorelease];
	}
}

- (NSImage *)scaledImageFromFile:(NSString *)source 
		               maxBounds:(NSSize)maxBounds
		                quality:(CGFloat)quality
{
	NSInteger width = maxBounds.width;
	NSInteger height = maxBounds.height;

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSImageRep *rep = nil;
    NSImageRep *output = nil;
    NSImage *scratch = nil;
    NSInteger w,h,nw,nh;
    NSData *bitmapData;
    
    rep = [NSImageRep imageRepWithContentsOfFile:source];
    
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
	CGFloat wr, hr;
	
	// ratios
	wr = w/(CGFloat)width;
	hr = h/(CGFloat)height;
	
	
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
    scratch = [[NSImage alloc] initWithSize:NSMakeSize(nw, nh)];
    
    // could not create image
    if (!scratch)
	{
		NSLog(@"Could not render image");
		[pool release];
		return nil;
    };
    
	// Handle PDFImageRep differently
	if(![rep isKindOfClass:[NSPDFImageRep class]])
	{
		// draw into image to scale it   
		[scratch autorelease];
		
		[scratch lockFocus];
		[NSGraphicsContext saveGraphicsState];
	
		[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
		
		[rep drawInRect:NSMakeRect(0.0, 0.0, nw, nh)];
		
		output = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0,0,nw,nh)];
	
		[NSGraphicsContext restoreGraphicsState];
		[scratch unlockFocus];
	} else {
		//NSPDFImageRep *pdf = (NSPDFImageRep *)rep;
		
		// We need to use a downscaled image instead
		/*NSData *pdfData = [pdf PDFRepresentation];
		
		NSImage *pdfImage = [[NSImage alloc] initWithData:pdfData];
		[pdfImage setScalesWhenResized:YES];
		[pdfImage setSize:NSMakeSize(nw,nh)];*/
		
		[scratch setFlipped:YES];
		
		[scratch lockFocus];
		[NSGraphicsContext saveGraphicsState];
		
		[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationLow];
		[[NSGraphicsContext currentContext] setShouldAntialias:NO];
		
		[rep drawInRect:NSMakeRect(0.0, 0.0, nw, nh)];
		
		[NSGraphicsContext restoreGraphicsState];
		[scratch unlockFocus];
		
		[pool release];
		[scratch autorelease];
		
		return scratch;
		
		//return pdfImage;
	}  
	
    
    // could not get result
    if (!output)
    {
		NSLog(@"Could not scale image");
		[pool release];
		return nil;
    };
    
    // save as JPEG - for Alternative 1
    NSDictionary *properties =
        [NSDictionary dictionaryWithObjectsAndKeys:
	    [NSNumber numberWithDouble:quality],
	    NSImageCompressionFactor, NULL];    
    
    bitmapData = [(NSBitmapImageRep *)output representationUsingType:NSJPEGFileType
				      properties:properties];
    
    // could not get result
    if (!bitmapData)
    {
		NSLog(@"Could not convert to JPEG");
		[pool release];
		return nil;
    };
    
	// Output to file
    //BOOL ret = [bitmapData writeToFile:dest atomically:YES];
	
	// Alternative 1
	NSImage *image = [[NSImage alloc] initWithData:bitmapData];
	
	// Alternative 2
	//NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(nw,nh)];
	//[image addRepresentation:output];	
	
	[output release];
	[pool release];
	
	return [image autorelease];
}

- (void)removeAllQueuedItems
{	
	/*[queue removeAllObjects];

	// Remove dummys from thumbnails
	NSArray *keys = [thumbnails allKeys];
	for(unsigned i = 0; i < [keys count]; i++)
	{
		NSImage *image =[thumbnails objectForKey:[keys objectAtIndex:i]];
		if([image isEqualTo:dummyImageThumbnail])
			[thumbnails removeObjectForKey:[keys objectAtIndex:i]];
	}
	
	// Remove dummys from icons
	keys = [icons allKeys];
	for(unsigned i = 0; i < [keys count]; i++)
	{
		NSImage *image = [icons objectForKey:[keys objectAtIndex:i]];
		if([image isEqualTo:dummyImageIcon])
			[icons removeObjectForKey:[keys objectAtIndex:i]];
	}*/
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

- (NSUInteger)retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
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
