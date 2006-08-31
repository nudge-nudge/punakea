//
//  PATag.h
//  punakea
//
//  Created by Johannes Hoffart on 15.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
treat this class as the abstract superclass for all Tags,
 no methods are implemented here, subclasses need to overwrite them all!
 */
@interface PATag : NSObject <NSCoding, NSCopying>
{
	NSString *name;
	NSString *query;
	NSCalendarDate *lastClicked;
	NSCalendarDate *lastUsed;
	unsigned long clickCount;
	unsigned long useCount;
}

// these functions need to be implemented by subclass
- (BOOL)isEqual:(id)other; /**< must overwrite */
- (id)copyWithZone:(NSZone *)zone; /**< must overwrite */
- (float)absoluteRating; /**< must overwrite */
- (float)relativeRatingToTag:(PATag*)otherTag; /**< must overwrite */

// these functions have been implemented, but
// subclasses may overwrite
- (id)initWithName:(NSString*)aName; /**< may overwrite */

- (NSString*)name; /**< may overwrite */
- (NSString*)query; /**< may overwrite */
- (NSCalendarDate*)lastClicked; /**< may overwrite */
- (NSCalendarDate*)lastUsed; /**< may overwrite */
- (unsigned long)clickCount; /**< may overwrite */
- (unsigned long)useCount; /**< may overwrite */

- (void)setName:(NSString*)aName; /**< may overwrite */
- (void)setQuery:(NSString*)aQuery; /**< may overwrite */
- (void)incrementClickCount; /**< may overwrite */
- (void)incrementUseCount; /**< may overwrite */
- (void)decrementUseCount; /**< may overwrite */

- (void)setUseCount:(int)count;
- (void)setClickCount:(int)count;

@end
