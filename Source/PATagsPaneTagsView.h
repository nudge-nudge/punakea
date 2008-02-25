//
//  PATagsPaneTagsView.h
//  punakea
//
//  Created by Daniel on 21.02.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PAInfoPaneSubview.h"
#import "TagAutoCompleteController.h"
#import "NNTagging/NNSelectedTags.h"
#import "NNTagging/NNTaggableObject.h"

// TODO actually this is in total violation of the MVC pattern? does that matter? should have its own controller maybe
@interface PATagsPaneTagsView : PAInfoPaneSubview {

	IBOutlet NSTokenField				*tagField;
	IBOutlet NSTextField				*editTagsLabel;
	
	IBOutlet TagAutoCompleteController	*tagAutoCompleteController;
	
	NSArray								*taggableObjects;
	NSArray								*initialTags;						/**< Tags that are present before editing. */
	
}

- (NSArray *)tags;
- (void)setTags:(NSArray *)someTags;
- (NSString *)label;
- (void)setLabel:(NSString *)aString;

- (NSArray *)taggableObjects;
- (void)setTaggableObject:(NNTaggableObject *)object;
- (void)setTaggableObjects:(NSArray *)objects;

- (NSTokenField *)tagField;

@end
