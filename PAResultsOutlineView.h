/* PAResultsOutlineView */

#import <Cocoa/Cocoa.h>

@interface PAResultsOutlineView : NSOutlineView
{
	NSMetadataQuery *query;
	NSMutableDictionary *userDefaults;
	NSString *userDefaultsFile;

}

- (NSMetadataQuery *)query;
- (void)setQuery:(NSMetadataQuery *)aQuery;

@end
