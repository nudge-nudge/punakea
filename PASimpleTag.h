//
//  PATag.h
//  punakea
//
//  Created by Johannes Hoffart on 15.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PATag.h"


@interface PASimpleTag : NSObject <PATag> {
	NSString *name;
	NSString *query;
	NSCalendarDate *lastClicked;
	NSCalendarDate *lastUsed;
	unsigned long clickCount;
	unsigned long useCount;
	id <PATag> currentBestTag;
	
	//position in view
	NSRect rectInView;
	BOOL highlight;
}

- (id)initWithName:(NSString*)aName;

	//NSCoding
- (id)initWithCoder:(NSCoder*)coder;
- (void)encodeWithCoder:(NSCoder*)coder;

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

- (void)setCurrentBestTag:(id <PATag>)aTag;
- (id <PATag>)currentBestTag;

- (float)absoluteRating;
- (float)relativeRating;

- (NSMutableDictionary*)viewAttributes;
- (void)drawInRect:(NSRect)rect withAttributes:(NSDictionary*)attributes;
- (NSSize)sizeWithAttributes:(NSDictionary*)attributes;
- (void)setHighlight:(BOOL)flag;

- (BOOL)isEqualToTag:(PASimpleTag*)otherTag;

@end
