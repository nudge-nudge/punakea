//
//  PATitleBarSearchButton.h
//  punakea
//
//  Created by Daniel Bär on 04.12.11.
//  Copyright 2012 nudge:nudge. All rights reserved.
//

#import "PATitleBarButton.h"
#import "NNTagging/NNTags.h"


@interface PATitleBarSearchButton : PATitleBarButton <NSTextFieldDelegate>
{
	NSSearchField				*searchField;
	
	BOOL						expanded;
	float						extensionWidth;
}

+ (PATitleBarSearchButton *)titleBarButton;		/**< Use this for init */

- (void)showSearchField:(id)sender;
- (void)abortSearch:(id)sender;
- (void)closeSearchField:(id)sender;

- (void)selectSearchMenuItemWithTag:(NSInteger)tag;

- (float)extensionWidth;
- (void)setExtensionWidth:(float)aWidth;

- (NSSearchField *)searchField;
- (void)setSearchField:(NSSearchField *)aSearchField;

@end
