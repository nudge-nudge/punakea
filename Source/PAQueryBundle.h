//
//  PAQueryBundle.h
//  punakea
//
//  Created by Daniel on 31.07.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>


/** Posted when one of the receiver's bundles did update. The userInfo dictionary
	contains the corresponding bundle. */
extern NSString * const PAQueryBundleDidUpdate;


@interface PAQueryBundle : NSObject {

	NSMutableArray			*results;
	NSString				*value;
	NSString				*bundlingAttribute;

}

- (void)addResultItem:(id)anItem;
- (NSString *)stringValue;
- (unsigned)resultCount;
- (id)resultAtIndex:(unsigned)idx;

- (NSArray *)results;
- (void)setResults:(NSArray *)newResults;
- (NSString *)value;
- (void)setValue:(NSString *)newValue;
- (NSString *)bundlingAttribute;
- (void)setBundlingAttribute:(NSString *)attribute;

@end
