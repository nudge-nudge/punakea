/* PATagCloud */

#import <Cocoa/Cocoa.h>
#import <math.h>
#import "NNTagging/NNTag.h"
#import "PATagButton.h"
#import "PADropManager.h"

@interface NSObject (PATagCloudDatasource)

- (NSMutableArray*)visibleTags;
- (NNTag*)currentBestTag;

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
	NNTag							*selectedTag; /**< currently selected tag */
	PATagButton						*activeButton; /**< currently selected tagButton */
	
	NSPoint							pointForNextTagRect; /**< saves the point for the next tag to be displayed */
	NSInteger								tagPosition; /**< holds the position where the new line starts */
	
	NSUserDefaultsController		*userDefaultsController; /**< holds user defaults for tag cloud */
	
	NSString						*displayMessage;
	
	PADropManager					*dropManager;
	
	BOOL							showsDropBorder;	
}

- (id)datasource;
- (void)setDatasource:(id)ds;
- (id)delegate;
- (void)setDelegate:(id)del;

- (void)reloadData;

- (NSString*)displayMessage;
- (void)setDisplayMessage:(NSString*)message;

- (NSMutableDictionary*)tagButtonDict;
- (void)setTagButtonDict:(NSMutableDictionary*)aDict;
- (void)selectUpperLeftButton;
- (void)selectTag:(NNTag*)tag;
- (void)removeActiveTagButton;

@end
