/* TaggerViewController */

#import <Cocoa/Cocoa.h>
#import "PATagger.h"
#import "PATagFactory.h"
#import "PASimpleTagFactory.h"
#import "PATag.h"
#import "PAFileBox.h"

@interface TaggerViewController : NSWindowController {
    IBOutlet PAFileBox *fileBox;
	IBOutlet NSTextField *tagField;
	
    IBOutlet NSArrayController *tags; /**< tag controller for all tags */
    IBOutlet NSArrayController *popularTags;
    IBOutlet NSArrayController *recentTags;
    IBOutlet NSArrayController *fileTags;
	
	PATagger *tagger;
	PATagFactory *factory;
}

- (void)controlTextDidEndEditing:(NSNotification *)aNotification;

- (void)addPopularTag;
- (void)addRecentTag;
- (void)removeTagFromFile;

@end
