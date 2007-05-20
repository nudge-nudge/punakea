//
//  PASourceItemCell.h
//  punakea
//
//  Created by Daniel on 29.03.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PASourceItem.h"
#import "NNTagging/NNTag.h"
#import "PAImageButton.h"


@interface PASourceItemCell : NSTextFieldCell {

	PASourceItem					*item;
	
}

@end
