//
//  FVUtilities.m
//  FileView
//
//  Created by Adam Maxwell on 2/6/08.
/*
 This software is Copyright (c) 2007-2010
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

#import "FVUtilities.h"
#import "zlib.h"

static Boolean __FVIntegerEquality(const void *v1, const void *v2) { return v1 == v2; }
static CFStringRef __FVIntegerCopyDescription(const void *value) { return (CFStringRef)[[NSString alloc] initWithFormat:@"%ld", (long)value]; }
static CFHashCode __FVIntegerHash(const void *value) { return (CFHashCode)value; }

static CFStringRef __FVObjectCopyDescription(const void *value) { return (CFStringRef)[[(id)value description] copy]; }
static CFHashCode __FVObjectHash(const void *value) { return [(id)value hash]; }
static Boolean __FVObjectEqual(const void *value1, const void *value2) { return (Boolean)[(id)value1 isEqual:(id)value2]; }
static const void * __FVObjectRetain(CFAllocatorRef alloc, const void *value) { return [(id)value retain]; }
static void __FVObjectRelease(CFAllocatorRef alloc, const void *value) { [(id)value release]; }

const CFDictionaryKeyCallBacks FVIntegerKeyDictionaryCallBacks = { 0, NULL, NULL, __FVIntegerCopyDescription, __FVIntegerEquality, __FVIntegerHash };
const CFDictionaryValueCallBacks FVIntegerValueDictionaryCallBacks = { 0, NULL, NULL, __FVIntegerCopyDescription, __FVIntegerEquality };
const CFSetCallBacks FVNSObjectSetCallBacks = { 0, __FVObjectRetain, __FVObjectRelease, __FVObjectCopyDescription, __FVObjectEqual, __FVObjectHash };
const CFSetCallBacks FVNSObjectPointerSetCallBacks = { 0, __FVObjectRetain, __FVObjectRelease, __FVObjectCopyDescription, NULL, NULL };

Boolean FVCFDictionaryGetIntegerIfPresent(CFDictionaryRef dict, const void *key, NSInteger *value)
{
    union { const void *pv; const NSInteger iv; } u;
    if (CFDictionaryGetValueIfPresent(dict, key, &u.pv)) {
        *value = u.iv;
        return TRUE;
    }
    return FALSE;
}

#pragma mark Timer

// Object that can be retained and released by the timer, but does not retain its ivars
@interface _FVNSObjectTimerInfo : NSObject
{
@public;
    id  target;
    SEL selector;
}
@end

@implementation _FVNSObjectTimerInfo
@end

static const void * __FVTimerInfoRetain(const void *info) { return [(id)info retain]; }
static void __FVTimerInfoRelease(const void *info) { [(id)info release]; }
static CFStringRef __FVTimerInfoCopyDescription(const void *info)
{
    _FVNSObjectTimerInfo *tmi = (void *)info;
    return (CFStringRef)[[NSString alloc] initWithFormat:@"_FVNSObjectTimerInfo = {\n\ttarget = %@,\n\tselector = %@\n}", tmi->target, NSStringFromSelector(tmi->selector)];    
}

static void __FVRunLoopTimerFired(CFRunLoopTimerRef timer, void *info)
{
    _FVNSObjectTimerInfo *tmi = info;
    [tmi->target performSelector:tmi->selector withObject:(id)timer];
}

CFRunLoopTimerRef FVCreateWeakTimerWithTimeInterval(NSTimeInterval interval, NSTimeInterval fireTime, id target, SEL selector)
{
    // This can't be a stack object, so timer creation invokes the context's retain callback.
    _FVNSObjectTimerInfo *tmi = [_FVNSObjectTimerInfo new];
    tmi->target = target;
    tmi->selector = selector;
    
    CFRunLoopTimerContext timerContext = {  0, tmi, __FVTimerInfoRetain, __FVTimerInfoRelease, __FVTimerInfoCopyDescription };
    CFRunLoopTimerRef timer = CFRunLoopTimerCreate(CFAllocatorGetDefault(), fireTime, interval, 0, 0, __FVRunLoopTimerFired, &timerContext);
    
    // now owned by the timer
    [tmi release];
    return timer;
}

#pragma mark Logging

void FVLogv(NSString *format, va_list argList)
{
    NSString *logString = [[NSString alloc] initWithFormat:format arguments:argList];
    
    char *buf = NULL;
    char stackBuf[1024];
    
    // add 1 for the NULL terminator (length arg to getCString:maxLength:encoding: needs to include space for this)
    NSUInteger requiredLength = ([logString maximumLengthOfBytesUsingEncoding:NSUTF8StringEncoding] + 1);
    
    if (requiredLength <= sizeof(stackBuf) && [logString getCString:stackBuf maxLength:sizeof(stackBuf) encoding:NSUTF8StringEncoding]) {
        buf = stackBuf;
    } else if (NULL != (buf = NSZoneMalloc(NULL, requiredLength * sizeof(char))) ){
        [logString getCString:buf maxLength:requiredLength encoding:NSUTF8StringEncoding];
    } else {
        fprintf(stderr, "unable to allocate log buffer\n");
    }
    [logString release];
    
    fprintf(stderr, "%s\n", buf);
    
    if (buf != stackBuf) NSZoneFree(NULL, buf);
}

void FVLog(NSString *format, ...)
{
    va_list list;
    va_start(list, format);
    FVLogv(format, list);
    va_end(list);
}

#pragma mark Pasteboard URL functions

BOOL FVPasteboardHasURL(NSPasteboard *pboard)
{ 	 
    NSArray *types = [pboard types];
    
    // quicker test than URLSFromPasteboard(); at least on 10.5, NSPasteboard has the UTI types
    if ([types containsObject:(id)kUTTypeURL] || [types containsObject:(id)kUTTypeFileURL] || [types containsObject:NSURLPboardType])
        return YES;
    
    // also catches case of file URL, which conforms to kUTTypeURL, and strings that might be URLs
    return [FVURLSFromPasteboard(pboard) count] > 0;
}

// NSPasteboard only lets us read a single webloc or NSURL instance from the pasteboard, which isn't very considerate of it.  Fortunately, we can create a Carbon pasteboard that isn't as fundamentally crippled (except in its moderately annoying API).  
NSArray *FVURLSFromPasteboard(NSPasteboard *pboard)
{
    OSStatus err;
    
    PasteboardRef carbonPboard;
    err = PasteboardCreate((CFStringRef)[pboard name], &carbonPboard);
    
    if (noErr == err)
        (void)PasteboardSynchronize(carbonPboard);
    
    ItemCount itemCount, itemIndex;
    if (noErr == err)
        err = PasteboardGetItemCount(carbonPboard, &itemCount);
    
    if (noErr != err)
        itemCount = 0;
    
    NSMutableArray *toReturn = [NSMutableArray arrayWithCapacity:itemCount];
    
    // this is to avoid duplication in the last call to NSPasteboard
    NSMutableSet *allURLsReadFromPasteboard = [NSMutableSet setWithCapacity:itemCount];
    
    // Pasteboard has 1-based indexing!
    
    for (itemIndex = 1; itemIndex <= itemCount; itemIndex++) {
        
        PasteboardItemID itemID;
        CFArrayRef flavors = NULL;
        CFIndex flavorIndex, flavorCount = 0;
        
        err = PasteboardGetItemIdentifier(carbonPboard, itemIndex, &itemID);
        if (noErr == err)
            err = PasteboardCopyItemFlavors(carbonPboard, itemID, &flavors);
        
        if (noErr == err)
            flavorCount = CFArrayGetCount(flavors);
        
        // webloc has file and non-file URL, and we may only have a string type
        CFURLRef destURL = NULL;
        CFURLRef fileURL = NULL;
        CFURLRef textURL = NULL;
        
        // flavorCount will be zero in case of an error...
        for (flavorIndex = 0; flavorIndex < flavorCount; flavorIndex++) {
            
            CFStringRef flavor;
            CFDataRef data;
            
            flavor = CFArrayGetValueAtIndex(flavors, flavorIndex);
            
            // !!! I'm assuming that the URL bytes are UTF-8, but that should be checked...
            
            /*
             UTIs determined with PasteboardPeeker
             Assert NULL URL on each branch; this will always be true since the pasteboard can only contain
             one flavor per type.  Using UTTypeConforms instead of UTTypeEqual could lead to a memory
             leak if there were multiple flavors conforming to kUTTypeURL (other than kUTTypeFileURL).
             The assertion silences a clang warning.
            */
            if (UTTypeEqual(flavor, kUTTypeFileURL)) {
                
                err = PasteboardCopyItemFlavorData(carbonPboard, itemID, flavor, &data);
                if (noErr == err && NULL != data) {
                    FVAPIParameterAssert(NULL == fileURL);
                    fileURL = CFURLCreateWithBytes(NULL, CFDataGetBytePtr(data), CFDataGetLength(data), kCFStringEncodingUTF8, NULL);
                    CFRelease(data);
                }
                
            } else if (UTTypeEqual(flavor, kUTTypeURL)) {
                
                err = PasteboardCopyItemFlavorData(carbonPboard, itemID, flavor, &data);
                if (noErr == err && NULL != data) {
                    FVAPIParameterAssert(NULL == destURL);
                    destURL = CFURLCreateWithBytes(NULL, CFDataGetBytePtr(data), CFDataGetLength(data), kCFStringEncodingUTF8, NULL);
                    CFRelease(data);
                }
                
            } else if (UTTypeEqual(flavor, kUTTypeUTF8PlainText)) {
                
                // this is a string that may be a URL; FireFox and other apps don't use any of the standard URL pasteboard types
                err = PasteboardCopyItemFlavorData(carbonPboard, itemID, kUTTypeUTF8PlainText, &data);
                if (noErr == err && NULL != data) {
                    FVAPIParameterAssert(NULL == textURL);
                    textURL = CFURLCreateWithBytes(NULL, CFDataGetBytePtr(data), CFDataGetLength(data), kCFStringEncodingUTF8, NULL);
                    CFRelease(data);
                    
                    // CFURLCreateWithBytes will create a URL from any arbitrary string
                    if (NULL != textURL && nil == [(NSURL *)textURL scheme]) {
                        CFRelease(textURL);
                        textURL = NULL;
                    }
                }
                
            }
            
            // ignore any other type; we don't care
            
        }
        
        // only add the textURL if the destURL or fileURL were not found
        if (NULL != textURL) {
            if (NULL == destURL && NULL == fileURL)
                [toReturn addObject:(id)textURL];
            
            [allURLsReadFromPasteboard addObject:(id)textURL];
            CFRelease(textURL);
        }
        // only add the fileURL if the destURL (target of a remote URL or webloc) was not found
        if (NULL != fileURL) {
            if (NULL == destURL) 
                [toReturn addObject:(id)fileURL];
            
            [allURLsReadFromPasteboard addObject:(id)fileURL];
            CFRelease(fileURL);
        }
        // always add this if it exists
        if (NULL != destURL) {
            [toReturn addObject:(id)destURL];
            [allURLsReadFromPasteboard addObject:(id)destURL];
            CFRelease(destURL);
        }
        
        if (NULL != flavors)
            CFRelease(flavors);
    }
    
    if (carbonPboard) CFRelease(carbonPboard);
    
    // NSPasteboard only allows a single NSURL for some idiotic reason, and NSURLPboardType isn't automagically coerced to a Carbon URL pboard type.  This step handles a program like BibDesk which presently adds a webloc promise + NSURLPboardType, where we want the NSURLPboardType data and ignore the HFS promise.  However, Finder puts all of these on the pboard, so don't add duplicate items to the array...since we may have already added the content (remote URL) if this is a webloc file.
    if ([[pboard types] containsObject:NSURLPboardType]) {
        NSURL *nsURL = [NSURL URLFromPasteboard:pboard];
        if (nsURL && [allURLsReadFromPasteboard containsObject:nsURL] == NO)
            [toReturn addObject:nsURL];
    }
    
    // ??? On 10.5, NSStringPboardType and kUTTypeUTF8PlainText point to the same data, according to pasteboard peeker; if that's the case on 10.4, we can remove this and the registration for NSStringPboardType.
    if ([[pboard types] containsObject:NSStringPboardType]) {
        // this can (and does) return nil under some conditions, so avoid an exception
        NSString *stringURL = [pboard stringForType:NSStringPboardType];
        NSURL *nsURL = stringURL ? [NSURL URLWithString:stringURL] : nil;
        if ([nsURL scheme] != nil && [allURLsReadFromPasteboard containsObject:nsURL] == NO)
            [toReturn addObject:nsURL];
    }
    
    return toReturn;
}

// Once we treat the NSPasteboard as a Carbon pboard, bad things seem to happen on Tiger (-types doesn't work), so return the PasteboardRef by reference to allow the caller to add more types to it or whatever.
BOOL FVWriteURLsToPasteboard(NSArray *URLs, NSPasteboard *pboard)
{
    OSStatus err;
    
    PasteboardRef carbonPboard;
    err = PasteboardCreate((CFStringRef)[pboard name], &carbonPboard);
    
    if (noErr == err)
        err = PasteboardClear(carbonPboard);
    
    if (noErr == err)
        (void)PasteboardSynchronize(carbonPboard);
    
    NSUInteger i, iMax = [URLs count];
    
    for (i = 0; i < iMax && noErr == err; i++) {
        
        NSURL *theURL = [URLs objectAtIndex:i];
        NSString *string = [theURL absoluteString];
        CFDataRef utf8Data = (CFDataRef)[string dataUsingEncoding:NSUTF8StringEncoding];
        
        // any pointer type; private to the creating application
        PasteboardItemID itemID = (void *)theURL;
        
        // Finder adds a file URL and destination URL for weblocs, but only a file URL for regular files
        // could also put a string representation of the URL, but Finder doesn't do that
        
        if ([theURL isFileURL]) {
            err = PasteboardPutItemFlavor(carbonPboard, itemID, kUTTypeFileURL, utf8Data, kPasteboardFlavorNoFlags);
        }
        else {
            err = PasteboardPutItemFlavor(carbonPboard, itemID, kUTTypeURL, utf8Data, kPasteboardFlavorNoFlags);
        }
    }
    
    if (carbonPboard) 
        CFRelease(carbonPboard);
    
    return noErr == err;
}

#pragma mark -

NSGraphicsContext *FVWindowGraphicsContextWithSize(NSSize size)
{
    NSRect rect = NSZeroRect;
    rect.size = size;
    NSWindow *window = [[NSWindow alloc] initWithContentRect:rect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
    [window autorelease];
    return [NSGraphicsContext graphicsContextWithWindow:window];
}

#pragma mark -

static OSStatus __FVGetVolumeRefNumForURL(NSURL *fileURL, FSVolumeRefNum *volume)
{
    NSCParameterAssert([fileURL isFileURL]);
    OSStatus err = noErr;
    FSRef fileRef;
    
    if (nil == fileURL || FALSE == CFURLGetFSRef((CFURLRef)fileURL, &fileRef))
        err = fnfErr;
    
    FSCatalogInfo catInfo;
    if (noErr == err)
        err = FSGetCatalogInfo(&fileRef, kFSCatInfoVolume, &catInfo, NULL, NULL, NULL);
    
    if (volume && noErr == err) *volume = catInfo.volume;
    return err;
}

// Checking bIsEjectable or bIsRemovable seems more sensible, but FireWire and iDisk volumes return 0 for both properties; iDisk returns 0 for bIsOnExternalBus also, so we have to check to see if it's internal.  Disk images return 0 fr bIsOnInternalBus.  An internal volume can be unmounted  via disk utility, but there should be a warning about open files.  More importantly, it won't happen because someone accidentally pulled a cable (network/USB/FireWire).
static bool __FVURLIsOnInternalVolume(NSURL *fileURL)
{
    NSCParameterAssert([fileURL isFileURL]);
    
    FSVolumeRefNum volume;
    OSStatus err = __FVGetVolumeRefNumForURL(fileURL, &volume);
    
    GetVolParmsInfoBuffer infoBuffer;
    memset(&infoBuffer, 0, sizeof(GetVolParmsInfoBuffer));
    
#if (__LP64__ || MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_5)
    if (noErr == err)
        err = FSGetVolumeParms(volume, &infoBuffer, sizeof(GetVolParmsInfoBuffer));
#else
    HIOParam paramBlock;
    memset(&paramBlock, 0, sizeof(HIOParam));
    
    paramBlock.ioNamePtr = NULL;
    paramBlock.ioVRefNum = volume;
    paramBlock.ioBuffer = (void *)&infoBuffer;
    paramBlock.ioReqCount = sizeof(GetVolParmsInfoBuffer);
    
    if (noErr == err)
        err = PBHGetVolParmsSync((HParmBlkPtr)&paramBlock);    
#endif
    return (noErr == err && (infoBuffer.vMExtendedAttributes & (1L << bIsOnInternalBus)) != 0);
}

// Secondary check.  See if the boot volume is on this volume; in that case, it's safe to use mmap() even if you're booted from a FireWire disk, since the entire system will die if the volume goes away.
static bool __FVURLIsOnBootVolume(NSURL *fileURL)
{
    FSVolumeRefNum volume, rootVolume;
    OSStatus err = __FVGetVolumeRefNumForURL(fileURL, &volume);
    if (noErr == err)
        err = __FVGetVolumeRefNumForURL([NSURL fileURLWithPath:NSOpenStepRootDirectory()], &rootVolume);
    return (noErr == err && volume == rootVolume);
}

// Tertiary check.  Same reasoning as __FVURLIsOnBootVolume; if the application's volume goes away, the app will die anyway. 
static bool __FVURLIsOnApplicationVolume(NSURL *fileURL)
{
    CFURLRef bundleURL = CFBundleCopyBundleURL(CFBundleGetMainBundle());
    FSVolumeRefNum bundleVolume, fileVolume;
    bool sameVolume;
    if (noErr == __FVGetVolumeRefNumForURL((NSURL *)bundleURL, &bundleVolume) && noErr == __FVGetVolumeRefNumForURL(fileURL, &fileVolume))
        sameVolume = (bundleVolume == fileVolume);
    else
        sameVolume = false;
    if (bundleURL) CFRelease(bundleURL);
    return sameVolume;
}

bool FVCanMapFileAtURL(NSURL *fileURL)
{
    // see http://www.cocoabuilder.com/archive/message/cocoa/2008/5/13/206506
    return (__FVURLIsOnInternalVolume(fileURL) || __FVURLIsOnBootVolume(fileURL)) || __FVURLIsOnApplicationVolume(fileURL);
}

@interface NSBezierPath (Leopard)
+ (NSBezierPath*)bezierPathWithRoundedRect:(NSRect)rect xRadius:(CGFloat)xRadius yRadius:(CGFloat)yRadius;
@end

@implementation NSBezierPath (RoundRect)

+ (NSBezierPath*)fv_bezierPathWithRoundRect:(NSRect)rect xRadius:(CGFloat)xRadius yRadius:(CGFloat)yRadius;
{    
    if ([self respondsToSelector:@selector(bezierPathWithRoundedRect:xRadius:yRadius:)])
        return [self bezierPathWithRoundedRect:rect xRadius:xRadius yRadius:yRadius];
    
    // Make sure radius doesn't exceed a maximum size to avoid artifacts:
    CGFloat mr = MIN(NSHeight(rect), NSWidth(rect));
    CGFloat radius = MIN(xRadius, 0.5f * mr);
    
    // Make sure silly values simply lead to un-rounded corners:
    if( radius <= 0 )
        return [self bezierPathWithRect:rect];
    
    NSRect innerRect = NSInsetRect(rect, radius, radius); // Make rect with corners being centers of the corner circles.
    NSBezierPath *path = [self bezierPath]; 
    
    // Now draw our rectangle:
    [path moveToPoint: NSMakePoint(NSMinX(innerRect) - radius, NSMinY(innerRect))];
    
    // Bottom left (origin):
    [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(innerRect), NSMinY(innerRect)) radius:radius startAngle:180.0 endAngle:270.0];
    // Bottom edge and bottom right:
    [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(innerRect), NSMinY(innerRect)) radius:radius startAngle:270.0 endAngle:360.0];
    // Left edge and top right:
    [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(innerRect), NSMaxY(innerRect)) radius:radius startAngle:0.0  endAngle:90.0 ];
    // Top edge and top left:
    [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(innerRect), NSMaxY(innerRect)) radius:radius startAngle:90.0  endAngle:180.0];
    // Left edge:
    [path closePath];
    
    return path;
}

@end
