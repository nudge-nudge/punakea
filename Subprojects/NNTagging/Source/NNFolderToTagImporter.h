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

#import "NNTags.h"
#import "NNFile.h"

#import "NNCommonNotifications.h"

/**
 Class to import an existing folder structure into Punakea.
 */
@interface NNFolderToTagImporter : NSObject {
	BOOL			managesFiles;
	
	NSFileManager	*fm;
	NSWorkspace		*ws;
}

- (void)setManagesFiles:(BOOL)flag;
- (BOOL)managesFiles;

/**
 Imports the given path by assigning tags according to 
 the folder structure. Will move files to managed folder
 if managesFiles is YES.
 
 E.g. /path/to/file.txt will result in tags "path" and "to"
 on file.txt
 
 @param importPath		Path to folder to import
 */
- (void)importPath:(NSString*)importPath;

@end
