//
//  PATagsPaneTagsView.h
//  punakea
//
//  Created by Daniel on 21.02.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PAInfoPaneSubview.h"
#import "TagAutoCompleteController.h"
#import "NNTagging/NNSelectedTags.h"


@interface PATagsPaneTagsView : PAInfoPaneSubview {

	IBOutlet NSTokenField				*tagField;
	IBOutlet NSTextField				*editTagsLabel;
	
	IBOutlet TagAutoCompleteController	*tagAutoCompleteController;
	
	NNSelectedTags						*selectedTags;
	
}

- (NSArray *)tags;
- (void)setTags:(NSArray *)someTags;
- (NSString *)label;
- (void)setLabel:(NSString *)aString;
- (NSTokenField *)tagField;

@end
