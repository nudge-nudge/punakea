//
//  PATagAutocompleteWindowController.h
//  punakea
//
//  Created by Daniel on 04.05.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NNTagging/NNTags.h"
#import "NNTagging/NNSelectedTags.h"
#import "NNTagging/NNRelatedTagsStandalone.h"
#import "PATypeAheadFind.h"


@interface PATagAutocompleteWindowController : NSWindowController {

	IBOutlet NSTokenField				*tagField;						/**< shows tags which are on all selected files */
	IBOutlet NSButton					*confirmButton;
	
	NNSelectedTags						*currentCompleteTagsInField;	/**< holds the relevant tags of tagField (as a copy) */
	NSString							*restDisplayString;
	
	NNTags								*globalTags;
	
	PATypeAheadFind						*typeAheadFind;
	
}

- (NNSelectedTags*)currentCompleteTagsInField;
- (void)setCurrentCompleteTagsInField:(NNSelectedTags*)newTags;

- (NSTokenField *)tagField;
- (NNSelectedTags *)currentCompleteTagsInField;
- (void)setCurrentCompleteTagsInField:(NNSelectedTags *)newTags;
- (NSString *)restDisplayString;
- (NNTags *)globalTags;
- (PATypeAheadFind *)typeAheadFind;

@end
