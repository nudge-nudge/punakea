//
//  PASelectedTagsView.h
//  punakea
//
//  Created by Johannes Hoffart on 31.03.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PATag.h"

/**
view for the selected tags
 */
@interface PASelectedTagsView : NSMatrix {
	IBOutlet NSArrayController *selectedTagsController;
	
	int cellWidth;
	int cellMaxWidth;
	int cellHeight;
	int cellMaxHeight;
}

@end
