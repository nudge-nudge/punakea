//
//  PAThumbnailManager.m
//  punakea
//
//  Created by Daniel on 30.08.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAThumbnailManager.h"


int const CONCURRENT_IMAGE_LOADING_MAX = 5;
int const NUMBER_OF_CACHED_ITEMS_MAX = 300;


@implementation PAThumbnailManager

static PAThumbnailManager *sharedInstance = nil;

#pragma mark Init + Dealloc 
- (id)sharedInstanceInit
{
	self = [super init];
	if(self)
	{
		numberOfThumbsBeingProcessed = 0;
		icons = [[NSMutableDictionary alloc] init];
		thumbnails = [[NSMutableDictionary alloc] init];
		queue = [[NSMutableArray alloc] init];
		stack = [[NSMutableArray alloc] init];
		
		dummyImageThumbnail = [NSImage imageNamed:@"dummyThumbLarge"];
		[dummyImageThumbnail setFlipped:YES];
		dummyImageIcon = [NSImage imageNamed:@"dummyThumbSmall"];
		[dummyImageIcon setFlipped:YES];
	}
	return self;
}

- (void)dealloc
{
	if(stack)					[stack release];
	if(queue)					[queue release];
	if(thumbnails)				[thumbnails release];
	if(icons)					[icons release];
	if(dummyImageThumbnail)		[dummyImageThumbnail release];
	if(dummyImageIcon)			[dummyImageIcon release];
	
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
		PAThumbnailItem *item = [[PAThumbnailItem alloc] initForFile:filename inView:aView frame:aFrame type:PAItemTypeThumbnail];		
		[queue addObject:item];
		[thumbnails setObject:dummyImageThumbnail forKey:filename];
		
		if(!timer)
		{
			timer = [NSTimer scheduledTimerWithTimeInterval:0.2
													 target:self
												   selector:@selector(processQueue)
												   userInfo:nil
													repeats:YES];
		}
		
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
	NSImage *icon = [icons objectForKey:filename];
	if(icon)
	{
		return icon;
	} else {		
		// Add filename to queue						
		PAThumbnailItem *item = [[PAThumbnailItem alloc] initForFile:filename inView:aView frame:aFrame type:PAItemTypeIcon];		
		[queue addObject:item];
		[icons setObject:dummyImageIcon forKey:filename];
		
		if(!timer)
		{
			timer = [NSTimer scheduledTimerWithTimeInterval:0.2
													 target:self
												   selector:@selector(processQueue)
												   userInfo:nil
													repeats:YES];
		}
		
		return dummyImageIcon;
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
		
		if([item type] == PAItemTypeThumbnail)
		{
			[ThreadWorker workOn:self
					withSelector:@selector(generateThumbnailFromFile:)
					  withObject:item
				  didEndSelector:nil];
		} else {
			[ThreadWorker workOn:self
					withSelector:@selector(generateIconForFile:)
					  withObject:item
				  didEndSelector:nil];
		}
	} 
	
	// If number of cached images exceeds limit, remove first item of stack
	if([stack count] > NUMBER_OF_CACHED_ITEMS_MAX)
	{
		NSString *filename = [stack objectAtIndex:0];
		
		[thumbnails removeObjectForKey:filename];
		[icons removeObjectForKey:filename];
		
		[stack removeObjectAtIndex:0];
		
		//NSLog(@"removed: %@", filename);
	}
}

- (void)generateThumbnailFromFile:(PAThumbnailItem *)thumbnailItem
{
	NSString *filename = [thumbnailItem filename];

	NSImage *thumbnail = [PAThumbnailManager thumbnailFromFileNew:filename maxBounds:NSMakeSize(76,75)];
	if([[thumbnailItem view] isFlipped]) [thumbnail setFlipped:YES];
	
	[thumbnails removeObjectForKey:filename];
	[thumbnails setObject:thumbnail forKey:filename];
	[stack addObject:filename];
	
	numberOfThumbsBeingProcessed--;
	
	// Refresh item's view
	NSView *view = [thumbnailItem view];
	NSRect frame = [thumbnailItem frame];
	[view setNeedsDisplayInRect:frame];
	
	[thumbnailItem release];
	
	//NSLog(@"finished %@", filename);
}

- (void)generateIconForFile:(PAThumbnailItem *)thumbnailItem
{
	NSString *filename = [thumbnailItem filename];

	NSImage *img = [[[NSWorkspace sharedWorkspace] iconForFile:filename] retain];
		
	[icons removeObjectForKey:filename];
	[icons setObject:img forKey:filename];
	[stack addObject:filename];
	
	numberOfThumbsBeingProcessed--;
	
	// Refresh item's view
	NSView *view = [thumbnailItem view];
	NSRect frame = [thumbnailItem frame];
	[view setNeedsDisplayInRect:frame];
	
	[img release];
}

+ (NSImage *)thumbnailFromFileNew:(NSString *)filename maxBounds:(NSSize)maxBounds
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
		0,imageOptions);
	
	// If this doesn't work, get ImageAtIndex
	if(image == NULL)
	{
		// This is the way it works
		//image = CGImageSourceCreateImageAtIndex(imageSourceRef,
		//	0,imageOptions);
		
		// This way of loading the whole file uses much less memory
		NSImage *img = [PAThumbnailManager scaledImageFromFile:filename maxBounds:maxBounds quality:0.8];
		
		CFRelease(imageSourceRef);
		
		return img;			
	} else {				
		// image size
		int w, nw, h, nh;
		w = nw = CGImageGetWidth(image);
		h = nh = CGImageGetHeight(image);
		
		if (w > maxBounds.width || h > maxBounds.height)
		{
			float wr, hr;
			
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

+ (NSImage *)scaledImageFromFile:(NSString *)source 
		               maxBounds:(NSSize)maxBounds
		                quality:(float)quality
{
	int width = maxBounds.width;
	int height = maxBounds.height;

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSImageRep *rep = nil;
    NSImageRep *output = nil;
    NSImage *scratch = nil;
    int w,h,nw,nh;
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
    
	// Handle PDFImageRep differently
	if(![rep isKindOfClass:[NSPDFImageRep class]])
	{
		// draw into image to scale it   
		
		[scratch lockFocus];
		[NSGraphicsContext saveGraphicsState];
	
		[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
		
		[rep drawInRect:NSMakeRect(0.0, 0.0, nw, nh)];
		
		output = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0,0,nw,nh)];
	
		[NSGraphicsContext restoreGraphicsState];
		[scratch unlockFocus];
	} else {
		NSPDFImageRep *pdf = rep;
		NSData *pdfData = [pdf PDFRepresentation];
		
		NSImage *pdfImage = [[NSImage alloc] initWithData:pdfData];
		[pdfImage setScalesWhenResized:YES];
		[pdfImage setSize:NSMakeSize(nw,nh)];
		
		return pdfImage;
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
	[queue removeAllObjects];

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
		NSImage *image =[icons objectForKey:[keys objectAtIndex:i]];
		if([image isEqualTo:dummyImageIcon])
			[icons removeObjectForKey:[keys objectAtIndex:i]];
	}
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
