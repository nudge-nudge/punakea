//
//  PAInfoPaneSingleSelectionView.h
//  punakea
//
//  Created by Daniel on 10.05.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PAInfoPaneSubview.h"
#import "NSTextFieldAdditions.h"
#import "NSDateFormatter+FriendlyFormat.h"


@interface PAInfoPaneSingleSelectionView : PAInfoPaneSubview {

	NNFile								*file;
	
	IBOutlet NSTextField				*kindLabel;
	IBOutlet NSTextField				*sizeLabel;
	IBOutlet NSTextField				*createdLabel;
	IBOutlet NSTextField				*modifiedLabel;
	IBOutlet NSTextField				*lastOpenedLabel;
	
	IBOutlet NSTextField				*kindField;
	IBOutlet NSTextField				*sizeField;
	IBOutlet NSTextField				*createdField;
	IBOutlet NSTextField				*modifiedField;
	IBOutlet NSTextField				*lastOpenedField;
	
}

- (NNFile *)file;
- (void)setFile:(NNFile *)aFile;

@end
