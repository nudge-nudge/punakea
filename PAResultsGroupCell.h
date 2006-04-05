//
//  PAResultsGroupCell.h
//  punakea
//
//  Created by Daniel on 05.04.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PAImageButton.h"


@interface PAResultsGroupCell : NSTextFieldCell {

	PAImageButton *triangle;
	NSMetadataQueryResultGroup *group;

}

@end
