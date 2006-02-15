//
//  PATagSet.h
//  punakea
//
//  Created by Johannes Hoffart on 15.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PATagSet : NSObject {
	NSString *name;
	NSArray *tags;
}

-(id)initWithTags:(NSArray*)newTags name:(NSString*)aName;

@end