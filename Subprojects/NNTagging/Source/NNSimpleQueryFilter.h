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
Use this if you want to add simple attribute - value constraints to the query.
 This is exactly the same as passing an additional string segment to MDQuery containing an
 attribute == value 
 expression.
 */
@interface NNSimpleQueryFilter : NNQueryFilter {
	NSString *attribute; /**< should contain the left-hand side of the constraint */
	NSString *value; /**< should contain the value of the attribute */
	
	BOOL valueUsesWildcard;
	NSString *options;		/**< such as cdw */
}

/**
 @param anAttribute		Left-hand side of the constraining expression
 @param aValue			Right-hand side of the constraining expression
 @return				Filter for anAttribute == aValue
 */
- (id)initWithAttribute:(NSString*)anAttribute value:(NSString*)aValue;

/**
 Convenience method.
 @param anAttribute		Left-hand side of the constraining expression
 @param aValue			Right-hand side of the constraining expression
 @return				Filter for anAttribute == aValue
 */ 
+ (NNSimpleQueryFilter*)simpleQueryFilterWithAttribute:(NSString*)anAttribute value:(NSString*)aValue;

/**
 @return Left-hand side of constraint
 */
- (NSString*)attribute;

/**
 @param anAttribute Left-hand side of expression
 */
- (void)setAttribute:(NSString*)anAttribute;

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
