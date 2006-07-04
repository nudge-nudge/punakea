//
//  PAResultsGroupCell.h
//  punakea
//
//  Created by Daniel on 05.04.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PAImageButton.h"
#import "PASegmentedImageControl.h"
#import "PAResultsOutlineView.h"


@interface PAResultsGroupCell : NSTextFieldCell {

	PAImageButton *triangle;
	PASegmentedImageControl *segmentedControl;
	NSDictionary *valueDict;
	BOOL hasMultipleDisplayModes;

}

- (NSString *)naturalLanguageGroupValue;
- (BOOL)hasMultipleDisplayModes;

//- (NSMetadataQueryResultGroup *)group;
//- (void)setGroup:(NSMetadataQueryResultGroup *)aGroup;

@end
