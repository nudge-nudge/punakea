// Copyright (c) 2006-2012 nudge:nudge (Johannes Hoffart & Daniel Bär). All rights reserved.
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

#import "PAPublicURLDropHandler.h"


@implementation PAPublicURLDropHandler

- (id)init
{
	if (self = [super init])
	{
		pboardType = [@"public.url" retain];
		dataHandler = [[PAURLDropDataHandler alloc] init];
	}
	return self;
}

- (BOOL)willHandleDrop:(NSPasteboard*)pasteboard
{
	// check for url	
	NSString *url = [pasteboard stringForType:pboardType];
	
	// ignore files
	if (url && ![pasteboard propertyListForType:NSFilenamesPboardType])
		return YES;
	else
		return NO;
}

- (NSArray*)handleDrop:(NSPasteboard*)pasteboard
{
	NSString *url = [pasteboard stringForType:pboardType];
	NSString *urlTitle = [pasteboard stringForType:@"public.url-name"];
	
	if (!urlTitle) 
	{
		// public.url-name is not available when dragging from Opera!
		// So just get the textual representation for the title matter
		urlTitle = [pasteboard stringForType:NSStringPboardType];
	}
		
	NSDictionary *urlDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:url,urlTitle,nil]
																  forKeys:[NSArray arrayWithObjects:@"url",@"title",nil]];
		
	return [NSArray arrayWithObject:[dataHandler fileDropData:urlDictionary]];
}

- (NSDragOperation)performedDragOperation:(NSPasteboard*)pasteboard
{
	if ([self willHandleDrop:pasteboard])
		return [dataHandler performedDragOperation];
	else
		return NSDragOperationNone;
}

@end
