//
//  PATagFactory.h
//  punakea
//
//  Created by Johannes Hoffart on 17.03.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PATag.h"

/**
This is the AbstractFactory, don't instantiate, use the subclasses - ObjC doesn't
 support abstract classes
 */
@interface PATagFactory : NSObject

/**
creates a tag with default values
 @return tag with default values
 */
- (PATag*)createTag;

/**
creates a tag with a specified name
 @param name new tag name
 @return tag with the given name
 */
- (PATag*)createTagWithName:(NSString*)name;

/**
creates a tag with a specified name and query (useful for non-simple tags)
 @param name new tag name
 @param query spotlight query the tag will execute when selected
 @return tag with the given name and query
 */
- (PATag*)createTagWithName:(NSString*)name query:(NSString*)query;


@end
