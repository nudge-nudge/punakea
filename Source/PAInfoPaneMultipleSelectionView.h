//
//  PAInfoPaneMultipleSelectionView.h
//  punakea
//
//  Created by Daniel on 16.05.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PAInfoPaneSubview.h";
#import "NSTextFieldAdditions.h"


@interface PAInfoPaneMultipleSelectionView : PAInfoPaneSubview {
	
	NSMutableArray						*files;
	
	IBOutlet NSTextField				*fromLabel;
	IBOutlet NSTextField				*toLabel;
	IBOutlet NSTextField				*itemsLabel;
	IBOutlet NSTextField				*sizeLabel;
	
	IBOutlet NSTextField				*fromField;
	IBOutlet NSTextField				*toField;
	IBOutlet NSTextField				*itemsField;
	IBOutlet NSTextField				*sizeField;
	
	NSDate								*fromDate;
	NSDate								*toDate;
	
}

- (NSArray *)files;
- (void)setFiles:(NSArray *)theFiles;

@end
