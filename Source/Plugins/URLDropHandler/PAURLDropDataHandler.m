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

#import "PAURLDropDataHandler.h"



@interface PAURLDropDataHandler (PrivateAPI)

- (NSData*)dragDataWithEntries:(NSArray*)entries;

@end

@implementation PAURLDropDataHandler

/**
data is NSDictionary with keys:
 "" : URL
 "title" : title
*/
- (NNTaggableObject*)fileDropData:(id)data
{
	NSString *url = [data objectForKey:@"url"];
	NSString *tempName = [[data objectForKey:@"title"] stringByAppendingString:@".webloc"];
	
	// replace non-file characters
	NSMutableString *copy = [[tempName mutableCopy] autorelease];
	[copy replaceOccurrencesOfString:@":" withString:@"_" options:0 range:NSMakeRange(0,[tempName length])];
	[copy replaceOccurrencesOfString:@"/" withString:@"_" options:0 range:NSMakeRange(0,[tempName length])];
	
	NSString *filename = copy;	
	NSString *filePath = [self destinationForNewFile:filename];
	
	NSMutableDictionary *weblocPlist = [NSMutableDictionary dictionaryWithCapacity:1];
	[weblocPlist setObject:url forKey:@"URL"];
	
	[weblocPlist writeToFile:filePath atomically:YES];
	
	// Hide WEBLOC extension
	NSDictionary *fileAttributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
															   forKey:NSFileExtensionHidden];
	
	[[NSFileManager defaultManager] setAttributes:fileAttributes
									 ofItemAtPath:filePath
											error:NULL];
	
	NNFile *weblocFile = [NNFile fileWithPath:filePath];
	return weblocFile;
}

- (NSDragOperation)performedDragOperation
{
		return NSDragOperationCopy;
}

@end
