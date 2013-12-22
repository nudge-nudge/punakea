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
#import "NNTaggableObject.h"
#import "NNTagStoreManager.h"
#import "NNTagToFileWriter.h"
#import "NSFileManager+Extensions.h"

#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <sys/xattr.h>

/** the key used when a tag's name is changed */
extern NSString * const NNFileSizeChangeOperation;

/**
Represents a file that can be tagged. Uses a subclass of NNTagReaderWriter to access the
 backing storage.
 */
@interface NNFile : NNTaggableObject {
	NSString				*path;
	
	NSString				*kind;
	
//	unsigned long long		sizeCached;
	
	NSWorkspace				*workspace;
	NSFileManager			*fileManager;
	NNTagStoreManager		*tagStoreManager;
}

/**
create a new NNFile from a path
 @param aPath path to file
 @return NNFile representing file at aPath
 */
- (id)initWithPath:(NSString*)aPath;

/**
 Use this initializer to create a file without
 ever accessing the spotlight db. This is currently
 the fastest way!
 @param aPath				Path to file
 @param aDisplayName		Display name to use
 @param aKind				File kind
 @param aContentType		Content type
 @param lastUsed			Date this file was last used
 @param aContentTypeTree	Content type tree
 @param someTags			tags on file
 @return					New NNFile for params
 */
- (id)initWithPath:(NSString*)aPath
	   displayName:(NSString*)aDisplayName
			  kind:(NSString*)aKind
	   contentType:(NSString*)aContentType
		  lastUsed:(NSDate*)lastUsed
   contentTypeTree:(NSArray*)aContentTypeTree
			  tags:(NSArray*)someTags;

// convenience initializers

/**
create a new NNFile from a path
 @param aPath path to file
 @return NNFile representing file at aPath
 */
+ (NNFile*)fileWithPath:(NSString*)aPath;

/**
create a new NSArray of NNFiles from a NSArray of file paths (NSString)
 @param filepaths paths to file (NSArray of NSString)
 @return NSArray of NNFiles representing file at aPath
 */
+ (NSArray*)filesWithFilepaths:(NSArray*)filepaths;


/**
 Use this initializer to create a file without
 ever accessing the spotlight db. This is currently
 the fastest way!
 */
+ (NNFile*)fileWithPath:(NSString*)aPath
			displayName:(NSString*)aDisplayName
				   kind:(NSString*)aKind
			contentType:(NSString*)aContentType
			   lastUsed:(NSDate*)lastUsed
		contentTypeTree:(NSArray*)aContentTypeTree
				   tags:(NSArray*)someTags;

// file wrapping stuff

/**
 @param path New file path
 */
- (void)setPath:(NSString*)path;

/**
 @return Full path including file.extension
 */
- (NSString*)path;

/**
 @return Standardized path (stringByStandardizingPath)
 */
- (NSString*)standardizedPath;

/**
 @return File name including extension
 */
- (NSString*)filename;

/**
 @return Full path as file URL
 */
- (NSURL*)url;

/**
 @return File extension
 */
- (NSString*)extension;

/**
 @return Directory path the file is located in
 */
- (NSString*)parentDirectory;

/**
 @return YES if file is a directory, NO otherwise
 */
- (BOOL)isDirectory;

/**
 @return Icon representing file
 */
- (NSImage*)icon;

/**
 @return ID of color label
 */
- (NSInteger)label;

/**
 @return A description of the kind of item this file represents
 */
- (NSString *)kind;

/**
 @return File creation date
 */
- (NSDate *)creationDate;

/**
 @return File modification date
 */
- (NSDate *)modificationDate;

/**
 @return File's logical size in bytes (data + resource fork). Does not work for folders.
 */
- (unsigned long long)size;
 
/**
Checks if the self is already located in the managed files directory (or a subdirectory).
 @return YES if this is the case, NO otherwise
 */
- (BOOL)isInManagedHierarchy;

// Compatibility
- (id)valueForAttribute:(id)attribute;

@end
