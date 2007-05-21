//
//  PASourcePanelController.h
//  punakea
//
//  Created by Daniel on 28.03.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PASourcePanel.h"
#import "PASourceItem.h"
#import "PASourceItemCell.h"
#import "PATagButton.h"
#import "NNTagging/NNTag.h"
#import "NNTagging/NNTagSet.h"
#import "NNTagging/NNSelectedTags.h"
#import "PASmartFolder.h"

extern NSString * const PAContentTypeFilterUpdate;


@interface PASourcePanelController : NSObject {

	IBOutlet PASourcePanel		*sourcePanel;
	
	NSMutableArray				*items;
	
	NSArray						*draggedItems;
	
}

- (void)addItem:(PASourceItem *)anItem;
- (void)addChild:(PASourceItem *)anItem toItem:(PASourceItem *)aParent;
- (void)removeItem:(PASourceItem *)anItem;

- (NSArray *)items;
- (NSArray *)draggedItems;

@end
