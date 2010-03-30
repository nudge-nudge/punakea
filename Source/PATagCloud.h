/* PATagCloud */

#import <Cocoa/Cocoa.h>
#import <math.h>
#import "NNTagging/NNTag.h"
#import "NNTagging/NNTags.h"
#import "PATagButton.h"
#import "PADropManager.h"
#import "PATagCloudProtocols.h"

extern NSSize const TAGCLOUD_PADDING;
extern NSSize const TAGCLOUD_SPACING;

/**
displays all tags in dataSource in a nice tag cloud view
 */
@interface PATagCloud : NSView
{
	id<PATagCloudDelegate>			delegate;
	id<PATagCloudDataSource>		dataSource;

	NSMutableDictionary				*tagButtonDict; /**< holds the current controls in the view */
	NNTag							*selectedTag; /**< currently selected tag */
	PATagButton						*activeButton; /**< currently selected tagButton */
	
	NSPoint							pointForNextTagRect; /**< saves the point for the next tag to be displayed */
	NSInteger						tagPosition; /**< holds the position where the new line starts */
	
	NSUserDefaultsController		*userDefaultsController; /**< holds user defaults for tag cloud */
	
	NSString						*displayMessage;
	
	PADropManager					*dropManager;
	
	BOOL							showsDropBorder;	
}

- (id<PATagCloudDataSource>)dataSource;
- (void)setDataSource:(id<PATagCloudDataSource>)ds;
- (id<PATagCloudDelegate>)delegate;
- (void)setDelegate:(id<PATagCloudDelegate>)del;

- (void)reloadData;

- (NNTag*)selectedTag;
- (void)setSelectedTag:(NNTag*)aTag;
- (PATagButton*)activeButton;
- (void)setActiveButton:(PATagButton*)aTag;

- (NSString*)displayMessage;
- (void)setDisplayMessage:(NSString*)message;

- (NSMutableDictionary*)tagButtonDict;
- (void)setTagButtonDict:(NSMutableDictionary*)aDict;
- (void)selectUpperLeftButton;
- (void)selectTag:(NNTag*)tag;
- (void)removeActiveTagButton;

@end
