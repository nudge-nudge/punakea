//
//  PATags.h
//  punakea
//
//  Created by Johannes Hoffart on 13.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PATags : NSObject {
	NSMutableArray* relatedTags;
	NSMutableArray* activeTags;
}

-(NSArray*)activeTags;

//collection type might change, don't depend on it too heavily
-(NSArray*)relatedTags;

@end