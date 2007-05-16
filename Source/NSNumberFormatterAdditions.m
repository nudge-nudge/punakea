//
//  NSNumberFormatterAdditions.m
//  punakea
//
//  Created by Daniel on 16.05.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "NSNumberFormatterAdditions.h"


@implementation NSNumberFormatter (NSNumberFormatterAdditions)

- (NSString *)stringFromFileSize:(unsigned long long)size
{
	float fileSize = [[NSNumber numberWithUnsignedLongLong:size] floatValue];
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
			
			NSNumber *n = [NSNumber numberWithFloat:fileSize];					
			fileSizeString = [NSString stringWithFormat:@"%@ MB", [self stringFromNumber:n]];
		}
		else
		{
			fileSize /= (1024 * 1024);
			
			NSNumber *n = [NSNumber numberWithFloat:fileSize];
			fileSizeString = [NSString stringWithFormat:@"%@ GB", [self stringFromNumber:n]];
		}
	}
	
	return fileSizeString;
}

@end
