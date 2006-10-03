//
//  PAResultsViewController.h
//  punakea
//
//  Created by Johannes Hoffart on 26.09.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PABrowserViewMainController.h"

#import "NSFileManager+TrashFile.h"

#import "PATagger.h"
#import "PATags.h"
#import "PATag.h"
#import "PARelatedTags.h"
#import "PASelectedTags.h"
#import "PAQuery.h"
#import "PAQueryBundle.h"
#import "PAQueryItem.h"
#import "PAResultsOutlineView.h"

@interface PAResultsViewController : PABrowserViewMainController {
	
	IBOutlet PAResultsOutlineView		*outlineView;
	
	PATagger							*tagger;
	PATags								*tags;
	PARelatedTags						*relatedTags;
	PASelectedTags						*selectedTags;
	
	PAQuery								*query;
	
	NSNotificationCenter				*nc;
}

- (void)handleTagActivation:(PATag*)tag;

- (PARelatedTags*)relatedTags;
- (void)setRelatedTags:(PARelatedTags*)otherRelatedTags;
- (PASelectedTags*)selectedTags;
- (void)setSelectedTags:(PASelectedTags*)otherSelectedTags;

- (PAQuery *)query;

- (IBAction)clearSelectedTags:(id)sender;

- (IBAction)setGroupingAttributes:(id)sender;

- (PAResultsOutlineView *)outlineView;

@end
