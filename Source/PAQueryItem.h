//
//  PAQueryItem.h
//  punakea
//
//  Created by Daniel on 31.07.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PAQueryItem : NSObject {

	NSMutableDictionary			*valueDict;

}

- (id)valueForAttribute:(NSString *)attribute;
- (void)setValue:(NSString *)value forAttribute:(NSString *)attribute;

@end
