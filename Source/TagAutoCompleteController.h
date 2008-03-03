//
//  TagAutoCompleteController.h
//  punakea
//
//  Created by Daniel on 01.02.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NNTagging/NNTags.h"
#import "NNTagging/NNSelectedTags.h"
#import "PATypeAheadFind.h"


@interface TagAutoCompleteController : NSObject {

	IBOutlet NSTokenField				*tagField;						
	
	NNSelectedTags						*currentCompleteTagsInField;	/**< holds the relevant tags of tagField (as a copy) */
	NSString							*restDisplayString;
	
	NNTags								*globalTags;
	
	PATypeAheadFind						*typeAheadFind;
	
}

- (NSTokenField *)tagField;

- (NNSelectedTags *)currentCompleteTagsInField;
- (void)setCurrentCompleteTagsInField:(NNSelectedTags *)newTags;

@end
