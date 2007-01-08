/* PATagCloud */

#import <Cocoa/Cocoa.h>
#import <math.h>
#import "PATagging/PATag.h"
#import "PATagButton.h"
#import "PADropManager.h"

@interface NSObject (PATagCloudDatasource)

- (NSMutableArray*)visibleTags;
- (PATag*)currentBestTag;
- (PATags*)tags; //TODO hide this properly!

@end

@interface NSObject (PATagCloudDelegate)

- (void)taggableObjectsHaveBeenDropped:(NSArray*)objects;
- (BOOL)isWorking;
- (void)makeControlledViewFirstResponder;

@end


extern NSSize const TAGCLOUD_PADDING;
extern NSSize const TAGCLOUD_SPACING;

/**
displays all [datasource visibleTags] in a nice tag cloud view
 */
@interface PATagCloud : NSView
{
	id								delegate;
	id								datasource;

	NSMutableDictionary				*tagButtonDict; /**< holds the current controls in the view */
	PATagButton						*activeButton; /**< currently selected tag */
	
	NSPoint							pointForNextTagRect; /**< saves the point for the next tag to be displayed */
	int								tagPosition; /**< holds the position where the new line starts */
	
	NSUserDefaultsController		*userDefaultsController; /**< holds user defaults for tag cloud */
	
	NSAttributedString				*noRelatedTagsMessage;
	NSAttributedString				*noTagsMessage;
	
	PADropManager					*dropManager;
	
	BOOL							showsDropBorder;
	BOOL							eyeCandy;
}

- (id)datasource;
- (void)setDatasource:(id)ds;
- (id)delegate;
- (void)setDelegate:(id)del;

- (NSMutableDictionary*)tagButtonDict;
- (void)setTagButtonDict:(NSMutableDictionary*)aDict;
- (PATagButton*)activeButton;
- (void)setActiveButton:(PATagButton*)aTag;
- (void)selectUpperLeftButton;

// called from outside
- (void)selectTag:(PATag*)tag;
- (void)removeActiveTagButton;

@end
