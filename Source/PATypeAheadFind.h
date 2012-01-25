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

#import <Cocoa/Cocoa.h>
#import "NNTagging/NNTags.h"

/**
simple type ahead find implementation, not the quickest, but works
 */
@interface PATypeAheadFind : NSObject {
	NNTags *tags; /**< all tags currently known */
	NSMutableArray *activeTags;
}


- (NSMutableArray*)activeTags;
- (void)setActiveTags:(NSMutableArray*)someTags;

/**
checks if there are any tags at all matching the prefix,
 this does not influence matchingTags:
 @param prefix prefix to look for
 @return true if there are any tags matching the prefix
 */
- (BOOL)hasTagsForPrefix:(NSString*)prefix;

- (NSMutableArray*)tagsForPrefix:(NSString*)prefix;
- (NSMutableArray*)tagsForPrefix:(NSString*)prefix inTags:(NSArray*)someTags;

@end
