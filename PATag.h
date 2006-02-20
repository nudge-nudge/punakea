//
//  PATag.h
//  punakea
//
//  Created by Johannes Hoffart on 15.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PATag : NSObject {
	NSString *name;
	NSString *query;
	int clickCount;
	int useCount;
}

- (id)initWithName:(NSString*)aName;
- (id)initWithName:(NSString*)aName query:(NSString*)aQuery;

- (NSString*)name;
- (NSString*)query;
- (int)clickCount;
- (int)useCount;

- (void)setName:(NSString*)aName;
- (void)setQuery:(NSString*)aQuery;
- (void)incrementClickCount;
- (void)incrementUseCount;

- (BOOL)isEqualToTag:(PATag*)otherTag;

@end
