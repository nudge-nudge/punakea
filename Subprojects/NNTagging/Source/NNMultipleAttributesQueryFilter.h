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

#import "NNQueryFilter.h"

@interface NNMultipleAttributesQueryFilter : NNQueryFilter
{
	NSMutableArray	*attributes;
	NSString		*value;
	
	BOOL valueUsesWildcard;
	NSString *options;		/**< such as cdw */
}

/**
 @param theAttributes	Left-hand side of the constraining expression
 @param aValue			Right-hand side of the constraining expression
 @return				Filter for anAttribute == aValue
 */
- (id)initWithAttributes:(NSArray*)theAttributes value:(NSString*)aValue;

/**
 Convenience method.
 @param theAttributes	Left-hand side of the constraining expression
 @param aValue			Right-hand side of the constraining expression
 @return				Filter for anAttribute == aValue
 */ 
+ (NNMultipleAttributesQueryFilter*)queryFilterWithAttributes:(NSArray*)theAttributes value:(NSString*)aValue;

/**
 @return Left-hand side of constraint
 */
- (NSArray*)attributes;

/**
 @param theAttributes Left-hand side of expression
 */
- (void)setAttributes:(NSArray*)theAttributes;

/**
 @return Right-hand side of expression
 */
- (NSString*)value;

/**
 @param aValue Right-hand side of expression
 */
- (void)setValue:(NSString*)aValue;

/**
 @return YES if expression should use wildcard for value, NO otherwise
 */
- (BOOL)valueUsesWildcard;

/**
 @param flag YES causes filter to use a wildcard for the value
 */
- (void)setValueUsesWildcard:(BOOL)flag;

/**
 @return Options to use, such as "cdw"
 */
- (NSString *)options;

/**
 @param theOptions Options to use, such as "cdw"
 */
- (void)setOptions:(NSString *)theOptions;


@end
