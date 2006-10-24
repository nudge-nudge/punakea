//
//  PARelatedTagsStandalone.h
//  punakea
//
//  Created by Johannes Hoffart on 08.07.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PARelatedTags.h"

/**
use this class if you want an encapsulated way to get related tags for the
 given selected tags
 
 use setSelectedTags to update the related tags (asynchronously)
 */
@interface PARelatedTagsStandalone : PARelatedTags

- (id)initWithSelectedTags:(PASelectedTags*)otherSelectedTags;

@end
