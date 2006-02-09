#import "ToolbarDelegateCategory.h"
#import "Controller.h"

@implementation Controller (ToolbarDelegateCategory)
- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar
    itemForItemIdentifier:(NSString *)itemIdentifier
    willBeInsertedIntoToolbar:(BOOL)flag
{
	NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
    return [item autorelease];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar
{
	return [NSArray arrayWithObjects:NSToolbarSeparatorItemIdentifier,
				     NSToolbarSpaceItemIdentifier,
				     NSToolbarFlexibleSpaceItemIdentifier,
				     NSToolbarCustomizeToolbarItemIdentifier, nil];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar
{
	   return [NSArray arrayWithObjects:NSToolbarFlexibleSpaceItemIdentifier,
				     NSToolbarCustomizeToolbarItemIdentifier, nil];
}
@end
