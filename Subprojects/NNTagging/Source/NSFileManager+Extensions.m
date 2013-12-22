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

#import "NSFileManager+Extensions.h"

#import "lcl.h"

@implementation NSFileManager (Extensions)


- (BOOL)isDirectoryAtPath:(NSString *)path;
{
	BOOL	isDirectory = NO;
	
	if ([self fileExistsAtPath:path isDirectory:&isDirectory]){
		// nothing
	}
	
	return isDirectory;
}

- (BOOL)isSymbolicLinkAtPath:(NSString *)path
{
	OSStatus			err = noErr;
	LSItemInfoRecord	infoRec;
	BOOL				isSymLink = NO;
	
	// create infoRec from path
	LSCopyItemInfoForURL((CFURLRef)[NSURL fileURLWithPath:path],
						 kLSRequestAllInfo,
						 &infoRec);
	
	if (err == noErr)
	{
		isSymLink = ( (infoRec.flags & kLSItemInfoIsSymlink) != 0 );
	}
	else
	{
		lcl_log(lcl_cnntagging,lcl_vWarning,@"Could not determine symlink status of directory '%@', assuming NO",path);
	}
	
	return isSymLink;	
}

- (BOOL)trashFileAtPath:(NSString *)path
{
	NSArray *files = [NSArray arrayWithObject:[path lastPathComponent]];
	NSString *sourceDir = [path stringByDeletingLastPathComponent]; 
	NSString *trashDir = [NSHomeDirectory() stringByAppendingPathComponent:@".Trash"];
	NSInteger tag;

	return [[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation
								  source:sourceDir destination:trashDir files:files tag:&tag];
}

- (NSString*)symlinkForFile:(NSString*)file inDirectory:(NSString*)directory
{
	NSString *pointer;
	
	BOOL success = [self symlinkExistsForFile:file
								  inDirectory:directory
									   atPath:&pointer];
	
	if (success)
		return pointer;
	else
		return nil;
}	

- (BOOL)symlinkExistsForFile:(NSString*)file inDirectory:(NSString*)directory atPath:(NSString**)symlinkPathPointer
{
	BOOL found = NO;
	NSError *error = nil;
	
	// check for symlink for the file
	NSString *fileName = [file lastPathComponent];
	
	if ([self isDirectoryAtPath:file]) {
		fileName = [NSString stringWithFormat:@"%@;",fileName];
	}
		
	*symlinkPathPointer = [directory stringByAppendingPathComponent:fileName];
	
	if ([self fileExistsAtPath:*symlinkPathPointer])
	{
		if ([[self destinationOfSymbolicLinkAtPath:*symlinkPathPointer error:&error] isEqualToString:file])
		{
			return YES;
		}
	}
	else
	{
		return NO;
	}
	
	// if there was no symlink pointing to the right file,
	// append suffices and check each one in turn
	NSInteger count = 0;
	
	while (YES)
	{
		count++;
		NSString *extension = [file pathExtension];
		
		if (![extension isEqualToString:@""])
		{
			NSString *nameWithoutExtension = [[file lastPathComponent] stringByDeletingPathExtension];
			*symlinkPathPointer = [directory stringByAppendingFormat:@"/%@-%lu.%@",nameWithoutExtension,count,extension];
		}
		else
		{
			*symlinkPathPointer = [directory stringByAppendingFormat:@"/%@-%lu",[file lastPathComponent],count];
		}
		
		if ([self fileExistsAtPath:*symlinkPathPointer])
		{
			if ([[self pathContentOfSymbolicLinkAtPath:*symlinkPathPointer] isEqualToString:file])
			{
				// a symlink to the passed file exists,
				// symlink points to its position
				found = YES;
				break;
			}
			else
			{
				// a symlink exists, but points to the wrong file,
				// continue checking - the continue is not necessary,
				// but helps understanding
				continue;
			}
		}
		else
		{
			// no file exists at the current symlink path, that means
			// the current symlink points to a valid path for a new symlink
			break;
		}
	}
	
	return found;
}

	

@end
