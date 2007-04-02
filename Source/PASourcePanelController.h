//
//  PASourcePanelController.h
//  punakea
//
//  Created by Daniel on 28.03.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PASourceItem.h"
#import "PASourceItemCell.h"
#import "PATagButton.h"
#import "NNTagging/NNTag.h"
#import "NNTagging/NNSelectedTags.h"
#import "PASmartFolder.h"


@interface PASourcePanelController : NSObject {

	NSMutableArray				*sourceItems;
	
	NSArray						*draggedItems;
	
}

- (NSArray *)draggedItems;

@end
