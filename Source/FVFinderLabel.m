//
//  FVFinderLabel.m
//  FileView
//
//  Created by Adam Maxwell on 1/12/08.
/*
 This software is Copyright (c) 2008-2010
 Adam Maxwell. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:
 
 - Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 
 - Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in
 the documentation and/or other materials provided with the
 distribution.
 
 - Neither the name of Adam Maxwell nor the names of any
 contributors may be used to endorse or promote products derived
 from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "FVFinderLabel.h"
#import "FVUtilities.h"

@implementation FVFinderLabel

static CFMutableDictionaryRef _layers = NULL;

+ (void)initialize
{
    FVINITIALIZE(FVFinderLabel);
    _layers = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &FVIntegerKeyDictionaryCallBacks, &kCFTypeDictionaryValueCallBacks);
}

typedef struct _FVRGBAColor { 
    CGFloat red;
    CGFloat green; 
    CGFloat blue;
    CGFloat alpha;
} FVRGBAColor;

typedef struct _FVGradientColor {
    FVRGBAColor color1;
    FVRGBAColor color2;
} FVGradientColor;

static void __FVLinearColorBlendFunction(void *info, const CGFloat *in, CGFloat *out)
{
    FVGradientColor *color = info;
    out[0] = (1.0 - *in) * color->color1.red + *in * color->color2.red;
    out[1] = (1.0 - *in) * color->color1.green + *in * color->color2.green;
    out[2] = (1.0 - *in) * color->color1.blue + *in * color->color2.blue;
    out[3] = (1.0 - *in) * color->color1.alpha + *in * color->color2.alpha;    
}

static void __FVLinearColorReleaseFunction(void *info)
{
    CFAllocatorDeallocate(CFAllocatorGetDefault(), info);
}

#define LABEL_ALPHA 1.0

+ (NSColor *)_lowerColorForFinderLabel:(NSUInteger)label
{
    NSColor *color = nil;
    NSColorSpace *cspace = [NSColorSpace genericRGBColorSpace];
    CGFloat components[4] = { 0, 0, 0, LABEL_ALPHA };
    NSUInteger numberOfComponents = sizeof(components)/sizeof(CGFloat);

    switch (label) {
        case 1:
            // gray 168	168	168
            components[0] = 168.0/255.0;
            components[1] = 168.0/255.0;
            components[2] = 168.0/255.0;
            color = [NSColor colorWithColorSpace:cspace components:components count:numberOfComponents];
            break;
        case 3:
            // purple 206	131	218
            components[0] = 206.0/255.0;
            components[1] = 131.0/255.0;
            components[2] = 218.0/255.0;
            color = [NSColor colorWithColorSpace:cspace components:components count:numberOfComponents];
            break;
        case 4:
            // blue 57	162	255
            components[0] =  57.0/255.0;
            components[1] = 162.0/255.0;
            components[2] = 255.0/255.0;
            color = [NSColor colorWithColorSpace:cspace components:components count:numberOfComponents];
            break;
        case 2:
            // green 164	221	61
            components[0] = 164.0/255.0;
            components[1] = 221.0/255.0;
            components[2] =  61.0/255.0;
            color = [NSColor colorWithColorSpace:cspace components:components count:numberOfComponents];
            break;
        case 5:
            // yellow 242	220	60
            components[0] = 242.0/255.0;
            components[1] = 220.0/255.0;
            components[2] =  60.0/255.0;
            color = [NSColor colorWithColorSpace:cspace components:components count:numberOfComponents];
            break;
        case 7:
            // orange  255	164	58
            components[0] = 255.0/255.0;
            components[1] = 164.0/255.0;
            components[2] =  58.0/255.0;
            color = [NSColor colorWithColorSpace:cspace components:components count:numberOfComponents];
            break;
        case 6:
            // red 255	77	87
            components[0] = 255.0/255.0;
            components[1] =  77.0/255.0;
            components[2] =  87.0/255.0;
            color = [NSColor colorWithColorSpace:cspace components:components count:numberOfComponents];
            break;
        default:
            components[3] = 0.0;
            color = [NSColor colorWithColorSpace:cspace components:components count:numberOfComponents];
            break;
    }
    return color;
}

+ (NSColor *)_upperColorForFinderLabel:(NSUInteger)label
{
    NSColor *color = nil;
    NSColorSpace *cspace = [NSColorSpace genericRGBColorSpace];
    CGFloat components[4] = { 0, 0, 0, LABEL_ALPHA };
    NSUInteger numberOfComponents = sizeof(components)/sizeof(CGFloat);
    
    switch (label) {
        case 1:
            // gray 207	207	207
            components[0] = 207.0/255.0;
            components[1] = 207.0/255.0;
            components[2] = 207.0/255.0;
            color = [NSColor colorWithColorSpace:cspace components:components count:numberOfComponents];
            break;
        case 3:
            // purple 229	188	236
            components[0] = 229.0/255.0;
            components[1] = 188.0/255.0;
            components[2] = 236.0/255.0;
            color = [NSColor colorWithColorSpace:cspace components:components count:numberOfComponents];
            break;
        case 4:
            // blue 160	212	255
            components[0] = 160.0/255.0;
            components[1] = 212.0/255.0;
            components[2] = 255.0/255.0;
            color = [NSColor colorWithColorSpace:cspace components:components count:numberOfComponents];
            break;
        case 2:
            // green 206	238	152
            components[0] = 206.0/255.0;
            components[1] = 238.0/255.0;
            components[2] = 152.0/255.0;
            color = [NSColor colorWithColorSpace:cspace components:components count:numberOfComponents];
            break;
        case 5:
            // yellow 251	245	151
            components[0] = 251.0/255.0;
            components[1] = 245.0/255.0;
            components[2] = 151.0/255.0;
            color = [NSColor colorWithColorSpace:cspace components:components count:numberOfComponents];
            break;
        case 7:
            // orange 255	206	145
            components[0] = 255.0/255.0;
            components[1] = 206.0/255.0;
            components[2] = 145.0/255.0;
            color = [NSColor colorWithColorSpace:cspace components:components count:numberOfComponents];
            break;
        case 6:
            // red 255	156	156
            components[0] = 255.0/255.0;
            components[1] = 156.0/255.0;
            components[2] = 156.0/255.0;
            color = [NSColor colorWithColorSpace:cspace components:components count:numberOfComponents];
            break;
        default:
            components[3] = 0.0;
            color = [NSColor colorWithColorSpace:cspace components:components count:numberOfComponents];
            break;
    }
    return color;
}

+ (NSString *)_preferenceNameForLabel:(NSInteger)label
{
    // Apple preference for Finder label names
    NSDictionary *labelPrefs = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.apple.Labels"];
    id name = [labelPrefs objectForKey:[NSString stringWithFormat:@"Label_Name_%d", label]];
    // check the class, since this is private
    if ([name isKindOfClass:[NSString class]] == NO)
        name = nil;
    return name;
}

+ (NSString *)localizedNameForLabel:(NSInteger)label
{
    FVAPIAssert1(label <= 7, @"Invalid Finder label %d (must be in the range 0--7)", label);
    NSString *name = [self _preferenceNameForLabel:label];
    NSBundle *bundle = [NSBundle bundleForClass:[FVFinderLabel self]];
    if (nil == name) {
        switch (label) {
            case 0:
                name = NSLocalizedStringFromTableInBundle(@"None", @"FileView", bundle, @"Finder label color");
                break;
            case 1:
                name = NSLocalizedStringFromTableInBundle(@"Gray", @"FileView", bundle, @"Finder label color");
                break;
            case 2:
                name = NSLocalizedStringFromTableInBundle(@"Green", @"FileView", bundle, @"Finder label color");
                break;
            case 3:
                name = NSLocalizedStringFromTableInBundle(@"Purple", @"FileView", bundle, @"Finder label color");
                break;
            case 4:
                name = NSLocalizedStringFromTableInBundle(@"Blue", @"FileView", bundle, @"Finder label color");
                break;
            case 5:
                name = NSLocalizedStringFromTableInBundle(@"Yellow", @"FileView", bundle, @"Finder label color");
                break;
            case 6:
                name = NSLocalizedStringFromTableInBundle(@"Red", @"FileView", bundle, @"Finder label color");
                break;
            case 7:
                name = NSLocalizedStringFromTableInBundle(@"Orange", @"FileView", bundle, @"Finder label color");
                break;
            default:
                name = nil; /* unreached */
                break;
        }
    }
    return name;
}

// Note: there is no optimization or caching here because this is only called once per color to draw the CGLayer
+ (void)_drawLabel:(NSUInteger)label inRect:(NSRect)rect ofContext:(CGContextRef)context;
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    FVGradientColor *gradientColor = CFAllocatorAllocate(CFAllocatorGetDefault(), sizeof(FVGradientColor), 0);
    
    NSColor *upperColor = [[self _upperColorForFinderLabel:label] colorUsingColorSpaceName:NSDeviceRGBColorSpace];
    NSColor *lowerColor = [[self _lowerColorForFinderLabel:label] colorUsingColorSpaceName:NSDeviceRGBColorSpace];
    
    // all colors were created using device RGB since we only draw to the screen, so we know that extracting components will work
    [lowerColor getRed:&gradientColor->color1.red green:&gradientColor->color1.green blue:&gradientColor->color1.blue alpha:&gradientColor->color1.alpha];
    [upperColor getRed:&gradientColor->color2.red green:&gradientColor->color2.green blue:&gradientColor->color2.blue alpha:&gradientColor->color2.alpha];
    
    // basic idea borrowed from OAGradientTableView and simplified
    const CGFloat domainAndRange[8] = { 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0 };
    const CGFunctionCallbacks linearFunctionCallbacks = {0, &__FVLinearColorBlendFunction, &__FVLinearColorReleaseFunction};
    CGFunctionRef linearBlendFunctionRef = CGFunctionCreate(gradientColor, 1, domainAndRange, 4, domainAndRange, &linearFunctionCallbacks);    
    CGContextSaveGState(context); 
    CGContextClipToRect(context, NSRectToCGRect(rect));
    CGShadingRef cgShading = CGShadingCreateAxial(colorSpace, CGPointMake(0, NSMinY(rect)), CGPointMake(0, NSMaxY(rect)), linearBlendFunctionRef, NO, NO);
    CGContextDrawShading(context, cgShading);
    CGShadingRelease(cgShading);
    CGContextRestoreGState(context);
    
    CGFunctionRelease(linearBlendFunctionRef);
    CGColorSpaceRelease(colorSpace);
}

+ (CGSize)_layerSize { return (CGSize) { 1, 32 }; }

+ (CGLayerRef)_layerForLabel:(NSUInteger)label context:(CGContextRef)context
{
    CGLayerRef layer = (void *)CFDictionaryGetValue(_layers, (const void *)label);    
    if (NULL == layer) {
        CGSize layerSize = [self _layerSize];
        if (NULL == context)
            context = [[NSGraphicsContext currentContext] graphicsPort];
        NSParameterAssert(NULL != context);
        layer = CGLayerCreateWithContext(context, layerSize, NULL);
        CGContextRef layerContext = CGLayerGetContext(layer);
        [self _drawLabel:label inRect:NSMakeRect(0, 0, layerSize.width, layerSize.height) ofContext:layerContext];
        CFDictionarySetValue(_layers, (const void *)label, layer);
        CGLayerRelease(layer);
    }
    return layer;
}

/*
 Hard to tell if Finder labels are rectangles with a semicircle cap or a round-cornered rect.
 */

static CGPathRef CreateRoundRectPathInRect(CGRect rect)
{
    // Make sure radius doesn't exceed a maximum size to avoid artifacts:
    CGFloat mr = MIN(CGRectGetHeight(rect), CGRectGetWidth(rect));
    
    // modification from NSBezierPath category: fixed radius of 6.5
    CGFloat radius = MIN(6.5, 0.5f * mr);
    
    // Make rect with corners being centers of the corner circles.
    CGRect innerRect = CGRectInset(rect, radius, radius);
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    // Now draw our rectangle:
    CGPathMoveToPoint(path, NULL, CGRectGetMinX(innerRect) - radius, CGRectGetMinY(innerRect));
    
    // Bottom left (origin):
    CGPathAddArc(path, NULL, CGRectGetMinX(innerRect), CGRectGetMinY(innerRect), radius, M_PI, 3 * M_PI_2, false);
    // Bottom edge and bottom right:
    CGPathAddArc(path, NULL, CGRectGetMaxX(innerRect), CGRectGetMinY(innerRect), radius, 3 * M_PI_2, 0, false);
    // Left edge and top right:
    CGPathAddArc(path, NULL, CGRectGetMaxX(innerRect), CGRectGetMaxY(innerRect), radius, 0, M_PI_2, false);
    // Top edge and top left:
    CGPathAddArc(path, NULL, CGRectGetMinX(innerRect), CGRectGetMaxY(innerRect), radius, M_PI_2, M_PI, false);
    // Left edge:
    CGPathCloseSubpath(path);
    
    return path;
}

static void ClipContextToRoundRectPathInRect(CGContextRef context, CGRect rect)
{
    CGPathRef path = CreateRoundRectPathInRect(rect);
    CGContextAddPath(context, path);
    CGContextClip(context);
    CGPathRelease(path);
}

static void ClipContextToCircleCappedPathInRect(CGContextRef context, CGRect rect)
{
    CGFloat radius = CGRectGetHeight(rect) / 2.0;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, CGRectGetMinX(rect) + radius, CGRectGetMinY(rect));
    CGPathAddArc(path, NULL, CGRectGetMinX(rect) + radius, CGRectGetMidY(rect), radius, -M_PI_2, M_PI_2, true);
    CGPathAddArc(path, NULL, CGRectGetMaxX(rect) - radius, CGRectGetMidY(rect), radius, M_PI_2, -M_PI_2, true);
    CGPathCloseSubpath(path);
    CGContextAddPath(context, path);
    CGContextClip(context);
    CGPathRelease(path);
}

+ (void)drawFinderLabel:(NSUInteger)label inRect:(CGRect)rect ofContext:(CGContextRef)context flipped:(BOOL)isFlipped roundEnds:(BOOL)flag;
{
    FVAPIAssert1(label <= 7, @"Invalid Finder label %d (must be in the range 0--7)", label);
    
    CGLayerRef layerToDraw = NULL;
    
    if (flag) {
        // create a temporary layer for drawing, so we avoid clipping the drawing context and ruining the shadow (if any)
        CGRect clippedRect = CGRectZero;
        clippedRect.size = rect.size;
        layerToDraw = CGLayerCreateWithContext(context, clippedRect.size, NULL);
        CGContextRef layerContext = CGLayerGetContext(layerToDraw);
        if (flag)
            ClipContextToRoundRectPathInRect(layerContext, clippedRect);
        else if (1)
            CGContextClipToRect(layerContext, clippedRect);
        else if (0) /* hack to silence gcc's unused function warning, since I may want to revert to this */
            ClipContextToCircleCappedPathInRect(layerContext, clippedRect);
        CGContextDrawLayerInRect(layerContext, clippedRect, [self _layerForLabel:label context:layerContext]);
    }
    else {
        layerToDraw = CGLayerRetain([self _layerForLabel:label context:context]);
    }
    
    CGContextSaveGState(context);
    if (isFlipped) {
        CGContextTranslateCTM(context, 0, CGRectGetMaxY(rect));
        CGContextScaleCTM(context, 1, -1);
        rect.origin.y = 0;
    }
    CGContextDrawLayerInRect(context, rect, layerToDraw);
    CGLayerRelease(layerToDraw);
    CGContextRestoreGState(context);
}

+ (void)drawFinderLabel:(NSUInteger)label inRect:(NSRect)rect roundEnds:(BOOL)flag;
{
    NSGraphicsContext *nsContext = [NSGraphicsContext currentContext];
    [self drawFinderLabel:label inRect:NSRectToCGRect(rect) ofContext:[nsContext graphicsPort] flipped:[nsContext isFlipped] roundEnds:flag];
}

+ (NSUInteger)finderLabelForURL:(NSURL *)aURL;
{
    FSRef fileRef;
    NSUInteger label = 0;
    
    if ([aURL isFileURL] && CFURLGetFSRef((CFURLRef)aURL, &fileRef)) {
        
        FSCatalogInfo catalogInfo;    
        OSStatus err;
        
        err = FSGetCatalogInfo(&fileRef, kFSCatInfoNodeFlags | kFSCatInfoFinderInfo, &catalogInfo, NULL, NULL, NULL);
        if (noErr == err) {
            
            // coerce to FolderInfo or FileInfo as needed and get the color bit
            if ((catalogInfo.nodeFlags & kFSNodeIsDirectoryMask) != 0) {
                FolderInfo *fInfo = (FolderInfo *)&catalogInfo.finderInfo;
                label = fInfo->finderFlags & kColor;
            }
            else {
                FileInfo *fInfo = (FileInfo *)&catalogInfo.finderInfo;
                label = fInfo->finderFlags & kColor;
            }
        }
    }
    return (label >> 1L);
}

+ (void)setFinderLabel:(NSUInteger)label forURL:(NSURL *)aURL;
{
    FSRef fileRef;
    
    FVAPIAssert1(label <= 7, @"Invalid Finder label %d (must be in the range 0--7)", label);
        
    if ([aURL isFileURL] && CFURLGetFSRef((CFURLRef)aURL, &fileRef)) {

        FSCatalogInfo catalogInfo;    
        OSStatus err;
        
        // get the current catalog info
        err = FSGetCatalogInfo(&fileRef, kFSCatInfoNodeFlags | kFSCatInfoFinderInfo, &catalogInfo, NULL, NULL, NULL);
        
        if (noErr == err) {
            
            label = (label << 1L);
            
            // coerce to FolderInfo or FileInfo as needed and set the color bit
            if ((catalogInfo.nodeFlags & kFSNodeIsDirectoryMask) != 0) {
                FolderInfo *fInfo = (FolderInfo *)&catalogInfo.finderInfo;
                fInfo->finderFlags &= ~kColor;
                fInfo->finderFlags |= (label & kColor);
            }
            else {
                FileInfo *fInfo = (FileInfo *)&catalogInfo.finderInfo;
                fInfo->finderFlags &= ~kColor;
                fInfo->finderFlags |= (label & kColor);
            }
            FSSetCatalogInfo(&fileRef, kFSCatInfoFinderInfo, &catalogInfo);
        }
    }
}

@end
