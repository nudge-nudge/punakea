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
@interface PATag : NSObject <NSCoding>

//equal
- (BOOL)isEqualToTag:(PATag*)otherTag;

- (NSString*)name;
- (NSString*)query;
- (NSCalendarDate*)lastClicked;
- (NSCalendarDate*)lastUsed;
- (unsigned long)clickCount;
- (unsigned long)useCount;

- (void)setName:(NSString*)aName;
- (void)setQuery:(NSString*)aQuery;
- (void)incrementClickCount;
- (void)incrementUseCount;

- (void)setCurrentBestTag:(PATag*)aTag;
- (PATag*)currentBestTag;

- (float)absoluteRating;
- (float)relativeRating;

- (NSMutableDictionary*)viewAttributes;
- (void)drawInRect:(NSRect)rect withAttributes:(NSDictionary*)attributes;
- (NSSize)sizeWithAttributes:(NSDictionary*)attributes;
- (void)setHighlight:(BOOL)flag;

@end
