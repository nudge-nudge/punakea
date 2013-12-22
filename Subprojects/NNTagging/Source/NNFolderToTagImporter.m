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

#import "NNFolderToTagImporter.h"

@implementation NNFolderToTagImporter

- (id)init
{
	if (self = [super init])
	{
		// default is not to move files on importing
		managesFiles = NO;
		
		fm = [NSFileManager defaultManager];
		ws = [NSWorkspace sharedWorkspace];
	}
	
	return self;
}

- (void)setManagesFiles:(BOOL)flag
{
	managesFiles = flag;
}
- (BOOL)managesFiles
{
	return managesFiles;
}

- (void)importPath:(NSString*)importPath
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; // Might be called in a background thread by BusyWindowController
    
	NNTags *sharedTags = [NNTags sharedTags];

	NSDirectoryEnumerator *e = [fm enumeratorAtPath:importPath];
	NSString *path;
	BOOL isDirectory;
	
	// first, count files in path
	NSUInteger current = 0;
	NSUInteger totalFiles = 0;
	
	while (path = [e nextObject])
	{
		NSString *fullPath = [importPath stringByAppendingPathComponent:path];
		NSString *name = [path lastPathComponent];
		
		if ([fm fileExistsAtPath:fullPath isDirectory:&isDirectory])
		{
			if (isDirectory)
			{
				// skip bundles and dot-directories - but count bundles!
				if ([name hasPrefix:@"."])
				{
					[e skipDescendents];
				}
				else if ([ws isFilePackageAtPath:fullPath])
				{
					[e skipDescendents];
					totalFiles++;
				}
			}
			else 
			{
				// it is a file
				if(![name hasPrefix:@"."])
				{
					// skip dot-files
					totalFiles++;			
				}
			}
		}
	}
	
	// post initial update notification - for busyWindow
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
	[userInfo setObject:[NSNumber numberWithDouble:0.1] forKey:@"currentProgress"];
	[userInfo setObject:[NSNumber numberWithDouble:(double)totalFiles] forKey:@"maximumProgress"];	
	[nc postNotificationName:NNProgressDidUpdateNotification
					  object:self 
					userInfo:userInfo];	
	
	// reset enumerator, do the real work
	e = [fm enumeratorAtPath:importPath];
	
	while (path = [e nextObject])
	{	
		NSString *fullPath = [importPath stringByAppendingPathComponent:path];
		NSString *name = [path lastPathComponent];
		
		if ([fm fileExistsAtPath:fullPath isDirectory:&isDirectory])
		{
			NNFile *file = nil;
			
			if (isDirectory)
			{
				// skip bundles and dot-directories - but tag bundles!
				if ([name hasPrefix:@"."])
				{
					[e skipDescendents];
				}
				else if ([ws isFilePackageAtPath:fullPath])
				{
					[e skipDescendents];
					file = [NNFile fileWithPath:fullPath];
				}
			}
			else
			{
				// it is a file - skip dot-files
				if (![name hasPrefix:@"."])
				{
					file = [NNFile fileWithPath:fullPath];
				}
			}
			
			// if file != nil, it should be tagged
			if (file != nil)
			{
				[file setShouldManageFiles:[self managesFiles]];
				
				NSArray *pathComponents = [path pathComponents];
				NSMutableArray *tagNames = [NSMutableArray arrayWithObject:[importPath lastPathComponent]];
				[tagNames addObjectsFromArray:[pathComponents subarrayWithRange:NSMakeRange(0, [pathComponents count]-1)]];
				
				NSArray *tags = [sharedTags tagsForNames:tagNames creationOptions:NNTagsCreationOptionFull];
				[file addTags:tags];
				
				current++;
				[userInfo setObject:[NSNumber numberWithDouble:(double)current] forKey:@"currentProgress"];
				[nc postNotificationName:NNProgressDidUpdateNotification 
								  object:self 
								userInfo:userInfo];
			}
		}
	}
    
    [pool release];
}

@end
