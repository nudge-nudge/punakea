//
//  FVUtilities.h
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

#ifndef _FVUTILITIES_H_
#define _FVUTILITIES_H_

#import <Cocoa/Cocoa.h>

__BEGIN_DECLS

/** @file FVUtilities.h  Various useful functions. */

/** @internal @var FVIntegerKeyDictionaryCallBacks
 For integer keys in a CFDictionary.  Do not use for toll-free bridging. */
FV_PRIVATE_EXTERN const CFDictionaryKeyCallBacks FVIntegerKeyDictionaryCallBacks;

/** @internal @var FVIntegerValueDictionaryCallBacks
 For integer values in a CFDictionary.  Do not use for toll-free bridging. */
FV_PRIVATE_EXTERN const CFDictionaryValueCallBacks FVIntegerValueDictionaryCallBacks;

/** @internal @var FVNSObjectSetCallBacks
 For NSObject subclasses in a CFSet.  Compatible with toll-free bridging. */
FV_PRIVATE_EXTERN const CFSetCallBacks FVNSObjectSetCallBacks;


/** @internal @var FVNSObjectPointerSetCallBacks
 For NSObject subclasses in a CFSet using pointer equality.  Compatible with toll-free bridging. */
FV_PRIVATE_EXTERN const CFSetCallBacks FVNSObjectPointerSetCallBacks;

/** @internal @brief For use with integer-valued dictionaries.
 @param dict CFDictionary with integer values.
 @param key Key of interest.
 @param value Pointer in which to return the value.
 @return TRUE if the key was present, FALSE if not present */  
FV_PRIVATE_EXTERN Boolean FVCFDictionaryGetIntegerIfPresent(CFDictionaryRef dict, const void *key, NSInteger *value);

/** @internal @brief Nonretaining timer.
 Creates a timer that does not retain its target; does not schedule the timer in a runloop.
 @param interval Fire interval.
 @param fireTime Absolute time of first firing.
 @param target Target for selector.
 @param selector Selector performed on each firing.  Should accept a single argument of type CFRunLoopTimerRef, as - (void)timerFired:(CFRunLoopTimerRef)tm.
 @return CFRunLoopTimerRef.  Caller is responsible for releasing this object. */
FV_PRIVATE_EXTERN CFRunLoopTimerRef 
FVCreateWeakTimerWithTimeInterval(CFAbsoluteTime interval, CFAbsoluteTime fireTime, id target, SEL selector);

/** @internal @brief Logging function. 
 Log to stdout without the date/app/pid gunk that NSLog appends */
FV_PRIVATE_EXTERN void FVLogv(NSString *format, va_list argList);
/** @internal @brief Logging function. 
 Log to stdout without the date/app/pid gunk that NSLog appends */
FV_PRIVATE_EXTERN void FVLog(NSString *format, ...);

/** @internal
 Checks the pasteboard for any URL data.  Converts an NSPasteboard to a Carbon PasteboardRef. 
 @param pboard Any NSPasteboard instance.
 @return YES if pboard has a URL type or a string that can be converted to a URL. */
FV_PRIVATE_EXTERN BOOL FVPasteboardHasURL(NSPasteboard *pboard);

/** @internal
 Reads URLs from the pasteboard, whether file: or other scheme.  Finder puts multiple URLs on the pasteboard, and also webloc files.  Converts an NSPasteboard to a Carbon PasteboardRef in order to work around NSPasteboard's terrible URL support.
 @param pboard Any NSPasteboard instance.
 @return An array of URLs from the pasteboard. */
FV_PRIVATE_EXTERN NSArray *FVURLSFromPasteboard(NSPasteboard *pboard);

/** @internal
 Writes URLs to the pasteboard as UTF-8 data.  Converts an NSPasteboard to a Carbon PasteboardRef in order to work around NSPasteboard's terrible URL support.
 @param URLs An array of URLs to write to the pasteboard.
 @param pboard Any NSPasteboard instance.
 @return YES if all URLs were written successfully. */
FV_PRIVATE_EXTERN BOOL FVWriteURLsToPasteboard(NSArray *URLs, NSPasteboard *pboard);

/** @internal
 Creates an NSGraphicsContext using an NSWindow as backing.  Intended for use in +initialize when +[NSGraphicsContext currentContext] may be nil.
 @param size Size of the window to create.
 @return A new, autoreleased instance of NSGraphicsContext. */
FV_PRIVATE_EXTERN NSGraphicsContext *FVWindowGraphicsContextWithSize(NSSize size);

/** @internal
 File URLs on remote/network and other volumes should not be memory mapped, or Very Bad Things can happen if the device goes away.  Call this as a heuristic to see if it's safe to use mmap(2).
 @param fileURL the URL to check.
 @return true if it's safe to mmap(2) the file. */
FV_PRIVATE_EXTERN bool FVCanMapFileAtURL(NSURL *fileURL);

/** @internal
 @brief NSBezierPath extensions for drawing round rects. */
@interface NSBezierPath (RoundRect)
/** Draw round rects.  On 10.5 and later, this is a wrapper for +[NSBezierPath bezierPathWithRoundedRect:xRadius:yRadius:].  On Tiger, yRadius is set equal to xRadius. */
+ (NSBezierPath*)fv_bezierPathWithRoundRect:(NSRect)rect xRadius:(CGFloat)xRadius yRadius:(CGFloat)yRadius;
@end

__END_DECLS

#endif /* _FVUTILITIES_H_ */
