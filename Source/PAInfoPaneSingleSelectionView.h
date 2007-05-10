//
//  PAInfoPaneSingleSelectionView.h
//  punakea
//
//  Created by Daniel on 10.05.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NNTagging/NNFile.h"
#import "NSTextFieldAdditions.h"


@interface PAInfoPaneSingleSelectionView : NSView {
	
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
	IBOutlet NSTokenField				*tagField;
	
}

- (NNFile *)file;
- (void)setFile:(NNFile *)aFile;

@end
