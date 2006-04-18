//
//  PAResultsMultiItem.h
//  punakea
//
//  Created by Daniel on 15.04.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PAResultsMultiItem : NSObject {
	
	NSMutableArray *items;
	NSMutableDictionary *tag;

}

- (NSArray *)items;
- (void)setItems:(NSArray *)theItems;
- (NSDictionary *)tag;
- (void)setTag:(NSDictionary *)aTag;

@end
