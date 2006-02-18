//
//  FileGroup.h
//  punakea
//
//  Created by Daniel on 18.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface FileGroup : NSObject {
	NSMutableDictionary * properties;
    //NSMutableArray      * files;
}

- (NSMutableDictionary *) properties;
- (void) setProperties: (NSDictionary *)newProperties;

//- (NSMutableArray *) files;
@end
