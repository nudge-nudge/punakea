//
//  ResultsOutlineViewController.h
//  punakea
//
//  Created by Daniel on 04.04.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PAResultsGroupCell.h"


@interface ResultsOutlineViewController : NSObject
{
	NSMetadataQuery *query;
}

- (NSMetadataQuery *)query;
- (void)setQuery:(NSMetadataQuery *)aQuery;
@end
