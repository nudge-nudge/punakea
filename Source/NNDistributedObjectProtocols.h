//
//  NNDistributedObjectProtocols.h
//  NNTagging
//
//  Created by Johannes Hoffart on 26.04.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol NNBVCServerProtocol

- (void)filteringStarted;
- (void)filteringFinished;

/** 
	will be called whenever new objects have been filtered
	filtered objects will be held in: filteredObjects
	use lockFilteredObjects before accessing, unlockFilteredObjects afterwards
*/
- (void)objectsFiltered;

@end
