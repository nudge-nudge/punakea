//
//  ResultsViewController.h
//  punakea
//
//  Created by Daniel on 26.09.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PAResultsOutlineView.h"
#import "PAQuery.h"
#import "PAResultsGroupCell.h"
#import "PAResultsItemCell.h"
#import "PAResultsMultiItemCell.h"


@interface ResultsViewController : NSObject {

	IBOutlet PAResultsOutlineView			*outlineView;

	PAQuery									*query;

}

@end
