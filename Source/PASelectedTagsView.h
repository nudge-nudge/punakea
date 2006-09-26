//
//  PASelectedTagsView.h
//  punakea
//
//  Created by Johannes Hoffart on 31.03.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PAResultsViewController.h"
#import "PATag.h"
#import "PASelectedTags.h"
#import "PAButton.h"

@interface PASelectedTagsView : NSView {
	
	IBOutlet PAResultsViewController	*controller;
	PASelectedTags						*selectedTags;
	
	NSMutableDictionary					*tagButtons;
	
}

@end
