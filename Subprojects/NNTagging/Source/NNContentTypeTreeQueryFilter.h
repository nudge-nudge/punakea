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

#import "NNQueryFilter.h"

/**
 Use this filter as a convenient way to filter the query by content type. The contentTypeIdentifier
 should resemble the right-hand side of MDSimpleGrouping.plist. NNContentTypeTreeQueryFilter will automatically
 filter for all corresponding left-hand sides.
 */
@interface NNContentTypeTreeQueryFilter : NNQueryFilter {
	NSString *contentTypeIdentifier;
	
	NSMutableString *predicate;
}

/**
 @param contentTypeIdentifier Pass a string resembling the contentType, i.e. the right-hand side of MDSimpleGrouping.plist (e.g. PDF)
 @return New filter for content type
 */
- (id)initWithType:(NSString*)contentTypeIdentifier;

/**
 Convenience method.
 
 @param contentTypeIdentifier Pass a string resembling the contentType, i.e. the right-hand side of MDSimpleGrouping.plist (e.g. PDF)
 @return New filter for content type
 */
+ (NNContentTypeTreeQueryFilter*)contentTypeTreeQueryFilterForType:(NSString*)contentTypeIdentifier;

@end
