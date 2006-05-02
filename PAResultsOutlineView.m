#import "PAResultsOutlineView.h"

@implementation PAResultsOutlineView

#pragma mark Init
- (void)awakeFromNib
{
	[self setIndentationPerLevel:0.0];
	[self setIntercellSpacing:NSMakeSize(0,1)];
	[[self delegate] setOutlineView:self];
	
	// Auto-size first column
	NSRect bounds = [self bounds];
	[[[self tableColumns] objectAtIndex:0] setWidth:bounds.size.width];		
}


#pragma mark Actions
- (void)reloadData
{
    while ([[self subviews] count] > 0)
    {
		[[[self subviews] lastObject] removeFromSuperviewWithoutNeedingDisplay];
    }
	    
    [super reloadData];
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self name:NSWindowDidResignKeyNotification object:nil];
	[nc addObserver:self
		   selector:@selector(windowDidChangeKeyNotification:)
			   name:NSWindowDidResignKeyNotification
			 object:newWindow];
	
	[nc removeObserver:self name:NSWindowDidBecomeKeyNotification object:nil];
	[nc addObserver:self
		   selector:@selector(windowDidChangeKeyNotification:)
			   name:NSWindowDidBecomeKeyNotification
			 object:newWindow];
}


#pragma mark Notifications
- (void)queryNote:(NSNotification *)note
{	
	if ([[note name] isEqualToString:NSMetadataQueryGatheringProgressNotification] ||
		[[note name] isEqualToString:NSMetadataQueryDidUpdateNotification] ||
		[[note name] isEqualToString:NSMetadataQueryDidFinishGatheringNotification])
	{
		[self reloadData];
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSArray *collapsedGroups = [[defaults objectForKey:@"Results"] objectForKey:@"CollapsedGroups"];
		
		int i;
		for(i = 0; i < [self numberOfRows]; i++)
			if([self levelForRow:i] == 0)
				if(![collapsedGroups containsObject:[[self itemAtRow:i] value]])
					[self expandItem:[self itemAtRow:i]];
	}
}

- (void)windowDidChangeKeyNotification:(NSNotification *)notification
{
	// Group rows need to change their background color
	[self setNeedsDisplay];
}


#pragma mark Accessors
- (NSMetadataQuery *)query
{
	return query;
}

- (void)setQuery:(NSMetadataQuery *)aQuery
{
	query = aQuery;
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(queryNote:) name:nil object:query];
	[[self delegate] setQuery:query];
}

@end
