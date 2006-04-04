/* PAResultsOutlineView */

#import <Cocoa/Cocoa.h>

@interface PAResultsOutlineView : NSOutlineView
{
	NSMetadataQuery *query;

}

- (NSMetadataQuery *)query;
- (void)setQuery:(NSMetadataQuery *)aQuery;

@end
