//
//  PASelectedTagsView.h
//  punakea
//
//  Created by Johannes Hoffart on 31.03.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BrowserViewController.h"
#import "PATag.h"
#import "PASelectedTags.h"
#import "PAButton.h"

@interface PASelectedTagsView : NSView {
	
	IBOutlet BrowserViewController		*browserViewController;
	PASelectedTags						*selectedTags;
	
	NSMutableDictionary					*tagButtons;
	
}

@end
