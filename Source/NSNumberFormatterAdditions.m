// Copyright (c) 2006-2011 nudge:nudge (Johannes Hoffart & Daniel Bär). All rights reserved.
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

#import "NSNumberFormatterAdditions.h"


@implementation NSNumberFormatter (NSNumberFormatterAdditions)

- (NSString *)stringFromFileSize:(unsigned long long)size
{
	CGFloat fileSize = [[NSNumber numberWithUnsignedLongLong:size] doubleValue];
	if(fileSize > 0 && fileSize < 4096)
		fileSize = 4096;
	
	fileSize /= 1024;	// file size in KB
	
	NSString *fileSizeString;
	
	if(fileSize < 1024)
	{
		[self setFormat:@"0"];
		
		NSNumber *n = [NSNumber numberWithDouble:fileSize];		
		fileSizeString = [NSString stringWithFormat:@"%@ KB", [self stringFromNumber:n]];
	}
	else
	{
		[self setFormat:@"0.0"];
		
		if(fileSize < 1024 * 1024)
		{
			fileSize /= 1024;
			
			NSNumber *n = [NSNumber numberWithDouble:fileSize];					
			fileSizeString = [NSString stringWithFormat:@"%@ MB", [self stringFromNumber:n]];
		}
		else
		{
			fileSize /= (1024 * 1024);
			
			NSNumber *n = [NSNumber numberWithDouble:fileSize];
			fileSizeString = [NSString stringWithFormat:@"%@ GB", [self stringFromNumber:n]];
		}
	}
	
	return fileSizeString;
}

@end
