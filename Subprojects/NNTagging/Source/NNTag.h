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

#import "FMDatabase.h"
#import "FMResultSet.h"

#import "NNTagStoreManager.h"

/**
Treat this class as the <b>abstract</b> superclass for all Tags,
 most of the methods are not implemented here, 
 subclasses need to overwrite!
 */
@interface NNTag : NSObject <NSCoding, NSCopying>
{
	NSString *name;
	NSString *query;
	NSDate *lastClicked;
	NSDate *lastUsed;
	NSUInteger clickCount;
	NSUInteger useCount;
}

- (id)initWithName:(NSString*)tagName
			 query:(NSString*)tagQuery
	   lastClicked:(NSDate*)clickDate
		  lastUsed:(NSDate*)useDate
		clickCount:(NSUInteger)clicks
		  useCount:(NSUInteger)uses;

// these functions need to be implemented by subclass

/** 
<b>must overwrite</b>

@param other NSObject to compare to
@return YES if equal; NO otherwise
*/
- (BOOL)isEqual:(id)other;

/** 
<b>must overwrite</b>

@param zone NSZone to use
@return copied NNTag subclass
*/
- (id)copyWithZone:(NSZone *)zone;

/** 
 <b>must overwrite</b>
 
 Use this method if you want to implement a tag renaming which updates the backing storage.
 
 @param aName new tag name
 */
- (void)renameTo:(NSString*)aName;

/** 
<b>must overwrite</b>

Tag rating should be between 0.0 and infinity.

@return Tag rating
*/
- (CGFloat)absoluteRating;

/** 
<b>must overwrite</b>

@param otherTag Tag to compare rating to
@return Value in [0.0,1.0]
*/
- (CGFloat)relativeRatingToTag:(NNTag*)otherTag;

/** 
<b>must overwrite</b>

This method is called when the tag should be removed from the backing storage.
*/
- (void)remove;


// these functions have been implemented, but
// subclasses may overwrite

/** 
<b>may overwrite</b>

 Initializes the tag with the given name. It will be decomposed to its canonical mapping, i.e. diacritics are 
 stored as separate characters.
 
 @param aName Name for the new tag
 @return NNTag subclass with aName
*/
- (id)initWithName:(NSString*)aName;

/** 
<b>may overwrite</b>

 @return The tag name that is represented in its decomposed form, i.e. diacritics are 
		  stored as separate characters.
*/
- (NSString*)name;

/** 
 <b>may overwrite</b>
 
 @return	The tag name that is represented in its precomposed form, i.e. diacritics are 
			stored as one single character.
 */
- (NSString*)precomposedName;

/** 
 <b>may overwrite</b>
 
 @param		aName			New tag name that will be decomposed to its canonical mapping, i.e. diacritics are 
							stored as separate characters.
 */
- (void)setName:(NSString*)aName;

/** 
 <b>may overwrite</b>
 
 @param aName New tag name
 @param decompose Decompose string with canonical mapping
 */
- (void)setName:(NSString*)aName decompose:(BOOL)decompose;

/** 
 <b>may overwrite</b>
 
 @return Query for this tag in spotlight syntax
 */
- (NSString*)query;

/**
 <b>may overwrite</b>
 
 @return Negated query for this tag in spotlight syntax
 */
- (NSString*)negatedQuery;

/** 
 <b>may overwrite</b>
 
 @param aQuery Query in spotlight syntax
 */
- (void)setQuery:(NSString*)aQuery;

/**
Executes a spotlight query for the tag. Blocks the thread until results have been gathered.
 @return NNTaggableObjects array for tag
 */
- (NSArray*)taggedObjects;

/** 
<b>may overwrite</b>

@return The time when this tag was most recently clicked
*/
- (NSDate*)lastClicked;

/** 
<b>may overwrite</b>

@param clickDate New last clicked date
*/
- (void)setLastClicked:(NSDate*)clickDate;

/** 
<b>may overwrite</b>

@return The time when this tag was most recently assigned to a NNTaggableObject
*/
- (NSDate*)lastUsed;

/** 
<b>may overwrite</b>

@param useDate New last used date
*/
- (void)setLastUsed:(NSDate*)useDate;

/** 
<b>may overwrite</b>

@return How often this tag was clicked
*/
- (NSUInteger)clickCount;

/** 
 <b>may overwrite</b>
 
 @param count New click count
 */
- (void)setClickCount:(NSUInteger)count;

/** 
 <b>may overwrite</b>
 
 @return How often this tag was used
 */
- (NSUInteger)useCount;

/** 
 <b>may overwrite</b>
 
 @param count New use count
 */
- (void)setUseCount:(NSUInteger)count;

/** 
<b>may overwrite</b>

Increments the click count.
*/
- (void)incrementClickCount;

/** 
<b>may overwrite</b>

Increments the use count.
*/
- (void)incrementUseCount;

/** 
<b>may overwrite</b>

decrements the use count
*/
- (void)decrementUseCount;

//--
// db stuff
//--

/**
 <b>may overwrite</b>
 
 Saves tag to sql store.
@return YES if successful
 */
- (BOOL)writeToTagDatabase;

/**
 <b>may overwrite</b>
 
 Removes tag from sql store.
 @return YES if successful
 */
- (BOOL)removeFromTagDatabase;

/**
 <b>may overwrite</b>
 
 Compares tag to another tag - by name.
 @return NSComparisonResult
 */
- (NSComparisonResult)compare:(id)object;

/**
 <b>may overwrite</b>
 
 Compares tag to another tag - by rating.
 @return NSComparisonResult
 */
- (NSComparisonResult)compareByRating:(id)object;

@end
