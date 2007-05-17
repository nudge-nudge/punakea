//
//  PATagSetPanel.h
//  punakea
//
//  Created by Daniel on 03.05.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PASourceItem.h"


@interface PATagSetPanel : NSPanel {

	// This outlet is a first draft. For future versions we need to distinguish
	// between simple and smart sets and offer more sophisticated accessors.
	IBOutlet NSTokenField				*tagField;
	
	PASourceItem						*sourceItem;
	
}

- (void)removeAllTags;

- (NSArray *)tags;
- (void)setTags:(NSArray *)someTags;
- (NSTokenField *)tagField;
- (PASourceItem *)sourceItem;
- (void)setSourceItem:(PASourceItem *)anItem;

@end
