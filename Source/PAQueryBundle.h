//
//  PAQueryBundle.h
//  punakea
//
//  Created by Daniel on 31.07.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


/** Posted when one of the receiver's bundles did update. The userInfo dictionary
	contains the corresponding bundle. */
extern NSString * const PAQueryBundleDidUpdate;


@interface PAQueryBundle : NSObject {

	NSMutableArray			*results;
	NSString				*value;

}

- (void)addResultItem:(id)anItem;

- (NSArray *)results;
- (void)setResults:(NSArray *)newResults;

@end
