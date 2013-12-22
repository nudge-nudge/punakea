// Copyright (c) 2006-2013 nudge:nudge (Johannes Hoffart & Daniel Bär). All rights reserved.
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Cocoa/Cocoa.h>

@interface NSFileManager (Extensions)

/**
 @param path	Path to check
 @return		YES if path is a directory, NO otherwise
 */
- (BOOL)isDirectoryAtPath:(NSString *)path;

/**
 @param path	Path to check
 @return		YES if path is a symbolic link, NO otherwise
 */
- (BOOL)isSymbolicLinkAtPath:(NSString *)path;

/**
 @param path	Path to move to trash
 @return		YES if successful, NO otherwise
 */
- (BOOL)trashFileAtPath:(NSString *)path;

/**
 Convenience method for symlinkExistsForFile:inDirectory:atPath:. Will return the path on YES, nil on NO
 @param file					Target file of the symlink to look for
 @param directory				Directory in which to look for the symlink
 @return						Path to symlink on YES, nil on NO
 */
- (NSString*)symlinkForFile:(NSString*)file inDirectory:(NSString*)directory;

/**
 If a symlink exists, this method will return YES and the passed symlinkPath pointer
 will be set to the correct symlink.
 Otherwise it will return NO and symlinkPath will point to a free path for the file.
 
 @param file					Target file of the symlink to look for
 @param directory				Directory in which to look for the symlink
 @param symlinkPathPointer		Pointer to an NSString. If method returns YES, it will contain the symlinkPath, otherwise
 it will point to a free place where to put a new symlink
 @return						YES if symlink exists, NO otherwise
 */
- (BOOL)symlinkExistsForFile:(NSString*)file inDirectory:(NSString*)directory atPath:(NSString**)symlinkPathPointer;

@end
