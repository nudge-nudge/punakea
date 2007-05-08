//
//  PASourcePanel.h
//  punakea
//
//  Created by Daniel on 28.03.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PASourceItem.h"
#import "NSBezierPathCategory.h"


@interface PASourcePanel : NSOutlineView {

}

- (void)selectItemWithValue:(NSString *)value;
- (void)reloadDataAndSelectItemWithValue:(NSString *)value;
- (PASourceItem *)itemWithValue:(NSString *)value;

- (void)removeSelectedItem;

@end
