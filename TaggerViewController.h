/* TaggerViewController */

#import <Cocoa/Cocoa.h>
#import "PATagger.h"
#import "PATag.h"

@interface TaggerViewController : NSWindowController {
    IBOutlet NSTextField *filePath;
    IBOutlet NSArrayController *tags; /**< tag controller for all tags */
    IBOutlet NSArrayController *popularTags;
    IBOutlet NSArrayController *recentTags;
    IBOutlet NSArrayController *fileTags;
	PATagger *tagger;
}

- (void)addPopularTag;
- (void)addRecentTag;
- (void)removeTagFromFile;

@end
