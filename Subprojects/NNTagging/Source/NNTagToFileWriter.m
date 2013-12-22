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


#import "NNTagToFileWriter.h"
#import "NNFile.h"

@implementation NNTagToFileWriter

#pragma mark functionality
- (NSArray*)allTaggedObjects
{
	NSLog(@"abstract method called: FAILURE");
	return nil;
}

- (BOOL)writeTags:(NSArray*)tags toFile:(NNFile*)file
{
	NSLog(@"abstract method called: FAILURE");
	return NO;
}

- (NSArray*)readTagsFromFile:(NNFile*)file
{
	return [self readTagsFromFile:file
				  creationOptions:NNTagsCreationOptionFull];
}

- (NSArray*)readTagsFromFile:(NNFile*)file 
			 creationOptions:(NNTagsCreationOptions)options
{
	NSLog(@"abstract method called: FAILURE");
	return nil;
}

- (NSString*)queryStringForTag:(NNSimpleTag*)tag
{
	NSLog(@"abstract method called: FAILURE");
	return nil;
}

- (NSString*)queryStringForTag:(NNSimpleTag*)tag negated:(BOOL)negated
{
	NSLog(@"abstract method called: FAILURE");
	return nil;
}

- (NSString*)spotlightMetadataField
{
	NSLog(@"abstract method called: FAILURE");
	return nil;
}

- (NSString*)scopeLimiter
{
	// this is not needed by default and can be empty
	return @"";
}

- (NSArray*)extractTagNamesFromSpotlightMetadataFieldValue:(id)tagsSpotlightMetadataFieldValue
{
	NSLog(@"abstract method called: FAILURE");
	return nil;
}

@end
