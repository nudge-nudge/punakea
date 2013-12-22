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


/** Posted when one of the receiver's bundles did update. The userInfo dictionary
	contains the corresponding bundle. */
extern NSString * const NNQueryBundleDidUpdate;


@interface NNQueryBundle : NSObject {

	NSMutableArray			*results;
	NSString				*value;
	NSString				*bundlingAttribute;
	
	NSMutableArray			*sortOrderArray;

}

/**
Creates a new NNQueryBundle
 @return new NNQueryBundle
 */
+ (NNQueryBundle *)bundle;

/**
 @param anItem NNTaggableObject to add
*/
- (void)addObject:(id)anItem;

/**
 @param anItem NNTaggableObject to look for
*/
- (BOOL)containsObject:(id)anItem;

/**
 @param anItem NNTaggableObject to remove
 */
- (void)removeObject:(id)anItem;

/**
 @return Name of this bundle, e.g. "PDF"
*/
- (NSString *)stringValue;

/**
 @return Number of results
*/
- (NSUInteger)resultCount;

/**
 @param idx Index of result to return
 @return NNTaggableObject at the given index
*/
- (id)resultAtIndex:(NSUInteger)idx;

/**
Sorts the results of this bundle by the given selector.
 @param comparator Selector to use for sorting
*/
- (void)sortUsingSelector:(SEL)comparator;

/**
 Sorts the results of this bundle by the given sort descriptors.
 @param comparator Descriptors to use for sorting
 */
- (void)sortUsingDescriptors:(NSArray*)sortDescriptors;

/**
 @return Results/contents of this bundle
*/
- (NSArray *)results;

/**
Sets a new array for results.
 @param newResults New results to use
*/
- (void)setResults:(NSArray *)newResults;

/**
 @return Value of this bundle, currently equal to stringValue, e.g. "PDF"
 */
- (NSString *)value;

/**
 @return Name of the bundle for display, e.g. "PDF Documents" instead of "PDF"
 */
- (NSString *)displayName;

/**
Sets the value of this bundle.
 @param newValue New value to use
*/
- (void)setValue:(NSString *)newValue;

/**
NOT IMPLEMENTED YET - bundling attribute to use for sub-bundling of results.
 @return Bundling attribute of sub-bundles
*/
- (NSString *)bundlingAttribute;

/**
NOT IMPLEMENTED YET - new bundling attribute to use fo sub-bundling of results.
 @param attribute New attribute to use for sub-bundling
*/
- (void)setBundlingAttribute:(NSString *)attribute;

@end
