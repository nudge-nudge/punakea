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
#import "NNTag.h"

extern NSString * const NNSelectedTagsHaveChangedNotification;


/**
Container class for selected tags. Needed for posting notifications, can be used
 as a NSMutableArray of sorts.
 */
@interface NNSelectedTags : NSObject {
	NSMutableArray *selectedTags;
	NSMutableSet *negatedTags; /**< tags included here are negated in the query */
	
	NNTag *lastTag;
	
	NSNotificationCenter *nc;
}

/**
Directly set some NNTags as selected tags.
 @param tags Tags to set
 @return Prepared selected tags
 */
- (id)initWithTags:(NSArray*)tags;

/**
@return Currently selected NNTags
 */
- (NSMutableArray*)selectedTags;

/**
@param otherTags Tags to set
 */
- (void)setSelectedTags:(NSArray*)otherTags;

/**
Removes most recently added selected tag.
 */
- (void)removeLastTag;

/**
Empties selected tags.
 */
- (void)removeAllTags;

/**
@return Number of selected tags
 */
- (NSUInteger)count;

/**
 Adds a tag to selected tags.

@param aTag NNTag to add
 */
- (void)addTag:(NNTag*)aTag;

/**
 Adds a tag to selected tags.
 
 @param negated If YES, tag is negated
 @param aTag NNTag to add
 */
- (void)addTag:(NNTag*)aTag negated:(BOOL)negated;

/**
 Adds all objects from someTags to selected tags.
 
@param someTags NSArray of NNTag objects to add
 */
- (void)addTags:(NSArray*)someTags;

/**
 Removes a tag (if present).
 
@param aTag NNTag to remove
 */
- (void)removeTag:(NNTag*)aTag;

/**
 Negates a tag, effectively excluding it from the search.
 Tagged objects with a negated tag are not shown in the results.
 
 @param aTag NNTag to negate
*/
- (void)negateTag:(NNTag*)aTag;

/**
 Toogles tag negation (@see negateTag:)
 
 @param aTag NNTag to toggle negation state
*/
- (void)toggleTagNegation:(NNTag*)aTag;

/**
 @return YES if aTag is negated, NO otherwise
 */
- (BOOL)isNegated:(NNTag*)aTag;

/**
 @param aTag NNTag to look for
 @return YES if selected tags contain aTag; NO otherwise
 */
- (BOOL)containsTag:(NNTag*)aTag;

/**
@return Enumerator for selected tags
 */
- (NSEnumerator*)objectEnumerator;

/**
Convenience method to add multiple NNTags.
 @param array NSArray of NNTags to add
 */
- (void)addObjectsFromArray:(NSArray*)array;

/** 
Convenience method to remove multiple NNTags.
@param array NSArray of NNTags to remove
*/
- (void)removeObjectsInArray:(NSArray*)array;

/**
Returns a query representing the selected tags for use in NNQuery
 */
- (NSMutableString*)queryString;

@end