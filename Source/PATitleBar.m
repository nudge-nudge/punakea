//
//  PATitleBar.m
//  punakea
//
//  Created by Daniel Bär on 04.12.11.
//  Copyright 2011 nudge:nudge. All rights reserved.
//

#import "PATitleBar.h"


NSSize const TITLEBAR_BUTTON_MARGIN = {7,0};

#define IN_RUNNING_LION (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6)

/** -----------------------------------------
 - There are 2 sets of colors, one for an active (key) state and one for an inactivate state
 - Each set contains 3 colors. 2 colors for the start and end of the title gradient, and another color to draw the separator line on the bottom
 - These colors are meant to mimic the color of the default titlebar (taken from OS X 10.6), but are subject
 to change at any time
 ----------------------------------------- **/

#define COLOR_MAIN_START [NSColor colorWithDeviceWhite:0.659 alpha:1.0]
#define COLOR_MAIN_END [NSColor colorWithDeviceWhite:0.812 alpha:1.0]
#define COLOR_MAIN_BOTTOM [NSColor colorWithDeviceWhite:0.318 alpha:1.0]

#define COLOR_NOTMAIN_START [NSColor colorWithDeviceWhite:0.851 alpha:1.0]
#define COLOR_NOTMAIN_END [NSColor colorWithDeviceWhite:0.929 alpha:1.0]
#define COLOR_NOTMAIN_BOTTOM [NSColor colorWithDeviceWhite:0.600 alpha:1.0]

/** Lion */

#define COLOR_MAIN_START_L [NSColor colorWithDeviceWhite:0.66 alpha:1.0]
#define COLOR_MAIN_END_L [NSColor colorWithDeviceWhite:0.9 alpha:1.0]
#define COLOR_MAIN_BOTTOM_L [NSColor colorWithDeviceWhite:0.408 alpha:1.0]

#define COLOR_NOTMAIN_START_L [NSColor colorWithDeviceWhite:0.878 alpha:1.0]
#define COLOR_NOTMAIN_END_L [NSColor colorWithDeviceWhite:0.976 alpha:1.0]
#define COLOR_NOTMAIN_BOTTOM_L [NSColor colorWithDeviceWhite:0.655 alpha:1.0]

/** Corner clipping radius **/
#define CORNER_CLIP_RADIUS 4.0

static CGImageRef createNoiseImageRef(int width, int height, float factor)
{
    int size = width*height;
    char *rgba = (char *)malloc(size); srand(124);
    for(int i=0; i < size; ++i){rgba[i] = rand()%256*factor;}
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapContext = 
    CGBitmapContextCreate(rgba, width, height, 8, width, colorSpace, kCGImageAlphaNone);
    CFRelease(colorSpace);
    free(rgba);
    CGImageRef image = CGBitmapContextCreateImage(bitmapContext);
    CFRelease(bitmapContext);
    return image;
}

@implementation PATitleBar

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
	{
		[self setAutoresizesSubviews:YES];
		
		if (IN_RUNNING_LION)
		{
			[[NSNotificationCenter defaultCenter] addObserver:self
													 selector:@selector(enterFullScreen:) 
														 name:NSWindowWillEnterFullScreenNotification 
													   object:[self window]];
			
			[[NSNotificationCenter defaultCenter] addObserver:self
													 selector:@selector(exitFullScreen:) 
														 name:NSWindowWillExitFullScreenNotification 
													   object:[self window]];
		}
    }
    
    return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (void)addSubview:(PATitleBarButton *)aView positioned:(PATitleBarButtonAlignment)place
{
	// Determine min x origin of all subviews
	float minx = self.frame.size.width;
	for (NSView *view in self.subviews)
	{
		if (view.frame.origin.x < minx)
			minx = view.frame.origin.x;
	}
	
	if (IN_RUNNING_LION && self.subviews.count == 0)
	{
		// Default fullscreen button width is 16, 13 is some arbitrary value.
		minx -= 16.0 + 13.0;
	}
	
	[aView sizeToFit];
	[aView setFrameOrigin:NSMakePoint(minx - TITLEBAR_BUTTON_MARGIN.width - aView.frame.size.width,
									  (self.frame.size.height - aView.frame.size.height) / 2.0)];
	[aView setAutoresizingMask:NSViewMinXMargin];
	
	[self addSubview:aView];
}

- (void)drawRect:(NSRect)dirtyRect
{
	float xoffset = 0.0;
	if (IN_RUNNING_LION)
	{
		NSButton *fsButton = [[self window] standardWindowButton:NSWindowFullScreenButton];
		[fsButton setFrameOrigin:NSMakePoint([self window].frame.size.width - 20.0 - TITLEBAR_BUTTON_MARGIN.width,
											 [self window].frame.size.height - self.frame.size.height + (self.frame.size.height - fsButton.frame.size.height) / 2.0 - 1.0)];
		
		xoffset = fsButton.frame.size.width + TITLEBAR_BUTTON_MARGIN.width;
	}
	
    BOOL drawsAsMainWindow = ([[self window] isMainWindow] && [[NSApplication sharedApplication] isActive]);
    NSRect drawingRect = [self bounds];
    drawingRect.size.height -= 1.0; // Decrease the height by 1.0px to show the highlight line at the top
    NSColor *startColor = nil;
    NSColor *endColor = nil;
    if (IN_RUNNING_LION) {
        startColor = drawsAsMainWindow ? COLOR_MAIN_START_L : COLOR_NOTMAIN_START_L;
        endColor = drawsAsMainWindow ? COLOR_MAIN_END_L : COLOR_NOTMAIN_END_L;
    } else {
        startColor = drawsAsMainWindow ? COLOR_MAIN_START : COLOR_NOTMAIN_START;
        endColor = drawsAsMainWindow ? COLOR_MAIN_END : COLOR_NOTMAIN_END;
    }
    [[self clippingPathWithRect:drawingRect cornerRadius:CORNER_CLIP_RADIUS] addClip];
    NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:startColor endingColor:endColor];
    [gradient drawInRect:drawingRect angle:90];
#if !__has_feature(objc_arc)
    [gradient release];
#endif
    if (IN_RUNNING_LION && drawsAsMainWindow) {
        static CGImageRef noisePattern = nil;
        if (noisePattern == nil) noisePattern = createNoiseImageRef(128, 128, 0.015);
        [NSGraphicsContext saveGraphicsState];
        [[NSGraphicsContext currentContext] setCompositingOperation:NSCompositePlusLighter];
        CGRect noisePatternRect = CGRectZero;
        noisePatternRect.size = CGSizeMake(CGImageGetWidth(noisePattern), CGImageGetHeight(noisePattern));        
        CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
        CGContextDrawTiledImage(context, noisePatternRect, noisePattern);
        [NSGraphicsContext restoreGraphicsState];
    }
    
    NSColor *bottomColor = nil;
    if (IN_RUNNING_LION) {
        bottomColor = drawsAsMainWindow ? COLOR_MAIN_BOTTOM_L : COLOR_NOTMAIN_BOTTOM_L;
    } else {
        bottomColor = drawsAsMainWindow ? COLOR_MAIN_BOTTOM : COLOR_NOTMAIN_BOTTOM;
    }
    NSRect bottomRect = NSMakeRect(0.0, NSMinY(drawingRect), NSWidth(drawingRect), 1.0);
    [bottomColor set];
    NSRectFill(bottomRect);
    
    if (IN_RUNNING_LION) {
        bottomRect.origin.y += 1.0;
        [[NSColor colorWithDeviceWhite:1.0 alpha:0.12] setFill];
        [[NSBezierPath bezierPathWithRect:bottomRect] fill];
    }
}

// Uses code from NSBezierPath+PXRoundedRectangleAdditions by Andy Matuschak
// <http://code.andymatuschak.org/pixen/trunk/NSBezierPath+PXRoundedRectangleAdditions.m>

- (NSBezierPath*)clippingPathWithRect:(NSRect)aRect cornerRadius:(CGFloat)radius
{
    NSBezierPath *path = [NSBezierPath bezierPath];
	NSRect rect = NSInsetRect(aRect, radius, radius);
    NSPoint cornerPoint = NSMakePoint(NSMinX(aRect), NSMinY(aRect));
    // Create a rounded rectangle path, omitting the bottom left/right corners
    [path appendBezierPathWithPoints:&cornerPoint count:1];
    cornerPoint = NSMakePoint(NSMaxX(aRect), NSMinY(aRect));
    [path appendBezierPathWithPoints:&cornerPoint count:1];
    [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(rect), NSMaxY(rect)) radius:radius startAngle:  0.0 endAngle: 90.0];
    [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(rect), NSMaxY(rect)) radius:radius startAngle: 90.0 endAngle:180.0];
    [path closePath];
    return path;
}

- (void)mouseUp:(NSEvent *)theEvent {
    if ([theEvent clickCount] == 2) {
        // Get settings from "System Preferences" >  "Appearance" > "Double-click on windows title bar to minimize"
        NSString *const MDAppleMiniaturizeOnDoubleClickKey = @"AppleMiniaturizeOnDoubleClick";
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults addSuiteNamed:NSGlobalDomain];
        BOOL shouldMiniaturize = [[userDefaults objectForKey:MDAppleMiniaturizeOnDoubleClickKey] boolValue];
        if (shouldMiniaturize) {
            [[self window] miniaturize:self];
        }
    }
}

- (void)performClickOnButtonWithIdentifier:(NSString *)anIdentifier
{
	for (PATitleBarButton *button in self.subviews)
	{
		if ([[button identifier] isEqualToString:anIdentifier])
		{
			[[button target] performSelector:[button action]];	
			break;
		}
	}
}

- (void)enterFullScreen:(NSNotification *)notification
{
	// Move all subviews to the right as there is not full screen button any more
	for (NSView *subview in self.subviews)
	{
		[subview setFrame:NSMakeRect(subview.frame.origin.x + 20.0,
									 subview.frame.origin.y,
									 subview.frame.size.width,
									 subview.frame.size.height)];
	}
	
}

- (void)exitFullScreen:(NSNotification *)notification
{
	// Move all subviews so that full screen button can be added to the right
	for (NSView *subview in self.subviews)
	{
		[subview setFrame:NSMakeRect(subview.frame.origin.x - 20.0,
									 subview.frame.origin.y,
									 subview.frame.size.width,
									 subview.frame.size.height)];
	}
}

@end
