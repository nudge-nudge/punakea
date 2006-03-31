//
//  PASelectedTagsView.h
//  punakea
//
//  Created by Johannes Hoffart on 31.03.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PATag.h"

@interface PASelectedTagsView : NSMatrix {
	IBOutlet NSArrayController *selectedTagsController;
}

@end
