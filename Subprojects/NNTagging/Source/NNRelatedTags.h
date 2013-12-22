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
#import "NNFile.h"
#import "NNTag.h"
#import "NNTags.h"
#import "NNQuery.h"
#import "NNSelectedTags.h"

/**
Finds related tags for a given query or a given selection of tags. Tags are related if they are on
 the same NNTaggableObject.

 Use this class if you want performance, it uses a query passed from the outside and observes its changes
  (i.e. from the browser).

 For a version with integrated query use NNRelatedTagsStandalone.
 
 posts NNRelatedTagsHaveChanged notification on update
 */
@interface NNRelatedTags : NSObject {
	NNTags *tags;
	
	NSMutableArray *relatedTags;
	BOOL updating;

	NSNotificationCenter *nc;
	NNQuery *query;
}

/**
Initializes related tags with some selected tags and a query.
 @param aQuery the query passed from the outside is observed and related tags adjusted periodically
 */
- (id)initWithQuery:(NNQuery*)aQuery;

/**
 @return Array of NNTags related to selectedTags:
*/
- (NSMutableArray*)relatedTags;

/**
 @return Count of currently found related Tags
 */
- (NSUInteger)count;

/**
@return YES if the related tags are currently updated; NO otherwise
 */
- (BOOL)isUpdating;

/**
@return YES if aTag is currently part of related tags; NO otherwise
 */
- (BOOL)containsTag:(NNTag*)aTag;

/**
Query to use for updating related tags
 @param aQuery NNQuery used to search for NNTaggableObjects
 */
- (void)setQuery:(NNQuery*)aQuery;

/**
Empties related tags
 */
- (void)removeAllTags;

@end