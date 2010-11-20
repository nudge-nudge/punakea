//
//  FVFinderLabel.h
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

#import <Cocoa/Cocoa.h>

/** Finder icon label interface.
 
 Finder labels are stored as integers in the filesystem, and are restricted to values 0--7.  Each integer corresponds to a color and name, which can be set in Finder's preferences.  Pass a value of 0 to clear the label.
 
 @warning Drawing methods are private to the framework.  Methods for getting and setting name and label may be useful to clients, and should be relatively stable. */
@interface FVFinderLabel : NSObject

/** @internal Draws a Finder label gradient in the specified context. */
+ (void)drawFinderLabel:(NSUInteger)label inRect:(CGRect)rect ofContext:(CGContextRef)context flipped:(BOOL)isFlipped roundEnds:(BOOL)flag;

/** @internal Draws a Finder label gradient in the currently focused graphics context. */
+ (void)drawFinderLabel:(NSUInteger)label inRect:(NSRect)rect roundEnds:(BOOL)flag;

/** Localized Finder label name.
 
 Returns the default label names, or attempts to read the hidden default com.apple.Labels if it exists. 
 @param label A value from 0--7. 
 @return the localized value of the label name. */
+ (NSString *)localizedNameForLabel:(NSInteger)label;

/** Label index for a given URL.
  
 @param aURL An absolute URL.  Non-file: URLs are ignored.
 @return Integer value from 0--7. */
+ (NSUInteger)finderLabelForURL:(NSURL *)aURL;

/* Change the label for a given URL
 
 This method raises an exception if an invalid label index is passed.
 
 @param label The valid range is 0--7 (pass 0 to clear the label).  
 @param aURL Non-file: URL and non-existent files are silently ignored. */
+ (void)setFinderLabel:(NSUInteger)label forURL:(NSURL *)aURL;

@end
