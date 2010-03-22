//
//  PATagManagementViewController.h
//  punakea
//
//  Created by Johannes Hoffart on 13.07.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PABrowserViewMainController.h"
#import "NNTagging/NNTags.h"
#import "NNTagging/NNTag.h"
#import "NSDateFormatter+FriendlyFormat.h"
#import "NSString+CharacterSetChecks.h"
#import "PAImageButton.h"

extern NSString * const PATagManagementOperation;
extern NSString * const PATagManagementRenameOperation;
extern NSString * const PATagManagementRemoveOperation;


@interface NSObject (PATagManagementViewControllerAdditions)

- (void)resetDisplayTags;

@end


@interface PATagManagementViewController : PABrowserViewMainController {
	
	IBOutlet NSProgressIndicator	*progressIndicator;
	IBOutlet NSTextField			*tagNameField;
	IBOutlet NSTextField			*lastClickedField;
	IBOutlet NSTextField			*totalClickedField;
	IBOutlet NSTextField			*lastUsedField;
	IBOutlet NSTextField			*totalUsedField;
	IBOutlet NSLevelIndicator		*popularityIndicator;
	IBOutlet NSView					*removeButtonPlaceholderView;
	PAImageButton					*removeButton;
	
	IBOutlet NSView					*simpleTagManagementView;
	
	NNTag							*currentEditedTag;
	
	NNTags							*tags;
	
}

- (NNTag*)currentEditedTag;
- (void)setCurrentEditedTag:(NNTag*)aTag;
- (BOOL)isWorking;

- (IBAction)renameOperation:(id)sender;
- (IBAction)removeOperation:(id)sender;

- (void)removeEditedTag;
- (void)renameEditedTagTo:(NSString*)newTagName;

@end
