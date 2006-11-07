//
//  PAFilterSlice.m
//  punakea
//
//  Created by Daniel on 31.07.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "PAFilterSlice.h"


NSSize const FILTERSLICE_PADDING = {10,5};
unsigned const FILTERSLICE_BUTTON_SPACING = 2;


@implementation PAFilterSlice

#pragma mark Init + Dealloc
- (id)initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
	if(self)
	{		
		buttons = [[NSMutableArray alloc] init];
		
		/* TODO not removed on controller change */
		[[NSNotificationCenter defaultCenter] addObserver:self
		                                         selector:@selector(update)
												     name:PAQueryDidUpdateNotification
												   object:[controller query]];
		[[NSNotificationCenter defaultCenter] addObserver:self
		                                         selector:@selector(update)
												     name:PAQueryDidFinishGatheringNotification
												   object:[controller query]];
		[[NSNotificationCenter defaultCenter] addObserver:self
		                                         selector:@selector(update)
												     name:PAQueryDidResetNotification
												   object:[controller query]];
		
		[self setupButtons];
		[self update];
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[buttons release];
	[super dealloc];
}


#pragma mark Actions
- (void)setupButtons
{
	for(unsigned i = 0; i < 8; i++)
	{	
		// Init button
		PAFilterButton *button = [[PAFilterButton alloc] initWithFrame:[self frame]];
		[button setAction:@selector(buttonClick:)];
		[button setTarget:self];
		[button setButtonType:PASwitchButton];
		[button setBezelStyle:PARecessedBezelStyle];
		
		// Define filter
		NSMutableDictionary *filter = [button filter];	
		switch(i)
		{
			case 0:		// ALL
				[filter setObject:@"All" forKey:@"title"];
				break;
			case 1:		// DOCUMENTS
				[filter setObject:@"DOCUMENTS" forKey:@"title"];
				[filter setObject:[NSArray arrayWithObject:@"DOCUMENTS"] forKey:@"filterValues"];
				[filter setObject:@"kMDItemContentTypeTree" forKey:@"filterBundlingAttribute"];
				break;
			case 2:		// MUSIC
				[filter setObject:@"MUSIC" forKey:@"title"];
				[filter setObject:[NSArray arrayWithObject:@"MUSIC"] forKey:@"filterValues"];
				[filter setObject:@"kMDItemContentTypeTree" forKey:@"filterBundlingAttribute"];
				//[filter setObject:[NSArray arrayWithObjects:(id)kMDItemAuthors, (id)kMDItemAlbum, nil] forKey:@"filterNewBundlingAttributes"];
				break;
			case 3:		// MOVIES	
				[filter setObject:@"MOVIES" forKey:@"title"];
				[filter setObject:[NSArray arrayWithObject:@"MOVIES"] forKey:@"filterValues"];
				[filter setObject:@"kMDItemContentTypeTree" forKey:@"filterBundlingAttribute"];
				break;
			case 4:		// PDF
				[filter setObject:@"PDF" forKey:@"title"];
				[filter setObject:[NSNumber numberWithInt:PAThumbnailMode] forKey:@"displayMode"];
				[filter setObject:[NSArray arrayWithObject:@"PDF"] forKey:@"filterValues"];
				[filter setObject:@"kMDItemContentTypeTree" forKey:@"filterBundlingAttribute"];
				break;
			case 5:		// IMAGES
				[filter setObject:@"IMAGES" forKey:@"title"];
				[filter setObject:[NSNumber numberWithInt:PAThumbnailMode] forKey:@"displayMode"];
				[filter setObject:[NSArray arrayWithObject:@"IMAGES"] forKey:@"filterValues"];
				[filter setObject:@"kMDItemContentTypeTree" forKey:@"filterBundlingAttribute"];
				break;
			case 6:		// CONTACT
				[filter setObject:@"CONTACT" forKey:@"title"];
				[filter setObject:[NSArray arrayWithObject:@"CONTACT"] forKey:@"filterValues"];
				[filter setObject:@"kMDItemContentTypeTree" forKey:@"filterBundlingAttribute"];
				break;
			case 7:		// BOOKMARKS
				[filter setObject:@"BOOKMARKS" forKey:@"title"];
				[filter setObject:[NSArray arrayWithObject:@"BOOKMARKS"] forKey:@"filterValues"];
				[filter setObject:@"kMDItemContentTypeTree" forKey:@"filterBundlingAttribute"];
				break;
		}
		
		// Determine button's title
		NSString *title = [[NSBundle mainBundle] localizedStringForKey:[filter objectForKey:@"title"]
																 value:[filter objectForKey:@"title"]
																 table:@"MDSimpleGrouping"];
		if(!title) title = @"All";
		[button setTitle:title];
		[button sizeToFit];
		
		// Add button to array
		[buttons addObject:button];
	}
}

- (void)update
{
	// Show or hide buttons
	[self updateButtons];
	
	NSEnumerator *enumerator = [buttons objectEnumerator];
	PAButton *button;
	PAButton *selectedButton = nil;
	while(button = [enumerator nextObject])
	{
		if([button isHighlighted])
		{
			selectedButton = button;
			break;
		}
	}
	
	if(!selectedButton || [selectedButton superview] != self)
	{
		// Select the ALL tab
		button = [buttons objectAtIndex:0];
		[self buttonClick:button];
	}
}

- (void)updateButtons
{
	float x = FILTERSLICE_PADDING.width;

	/*NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *spotlightDict = [defaults persistentDomainForName:@"com.apple.spotlight"];
	
	NSMutableArray *orderedItems = [[spotlightDict objectForKey:@"orderedItems"] mutableCopy];*/
	
	NSEnumerator *enumerator = [buttons objectEnumerator];
	PAFilterButton *button;
	while(button = [enumerator nextObject])
	{
		NSDictionary *filter = [button filter];
	
		BOOL hasResults;
		if(x == FILTERSLICE_PADDING.width)
		{
			hasResults = YES;	// The ALL tab is always there
		} else {
			hasResults = [[controller query] hasResultsUsingFilterWithValues:[filter objectForKey:@"filterValues"]
		                                                forBundlingAttribute:[filter objectForKey:@"filterBundlingAttribute"]];
		}
	
		NSRect frame = [button frame];
		frame.origin.x = x;
		frame.origin.y = FILTERSLICE_PADDING.height;
		
		if(hasResults)
		{
			NSRect buttonFrame = [button frame];
			x += buttonFrame.size.width + FILTERSLICE_BUTTON_SPACING;
		
			if([button superview] != self) [self addSubview:button];
			
			[button setFrame:frame];
		} else {
			if([button superview] == self) [button removeFromSuperview];
		}
	}
	
	[self setNeedsDisplay:YES];
}

- (void)buttonClick:(id)sender
{
	[[self window] makeFirstResponder:self];

	// Highlight active filter button
	NSEnumerator *enumerator = [buttons objectEnumerator];
	NSButton *button;
	while(button = [enumerator nextObject])
	{
		if(button != sender)
		{
			[button setState:PAOffState];
			[button highlight:NO];
		} else {
			[button highlight:YES];
		}
		[button setNeedsDisplay];
	}
	
	// Reset queue of ThumbnailManager. We don't need to process images that are not visible any more
	[[PAThumbnailManager sharedInstance] removeAllQueuedItems];
	
	PAQuery *query = [controller query];
	NSDictionary *filter = [sender filter];
	
	// Bundlings attributes that we set here need to be wrapped into an PAQueryItem in 
	// PAQuery's bundleResults:byAttributes:objectWrapping!! Only a few are there yet! TODO!
	if([[buttons objectAtIndex:0] isEqualTo:sender])
	{
		[query filterResults:NO usingValues:nil forBundlingAttribute:nil
				      newBundlingAttributes:nil];
	} else {
		[query filterResults:YES usingValues:[filter objectForKey:@"filterValues"]
						forBundlingAttribute:[filter objectForKey:@"filterBundlingAttribute"]
					   newBundlingAttributes:[filter objectForKey:@"filterNewBundlingAttributes"]];
	}
	
	// Set display mode
	if([filter objectForKey:@"displayMode"])
	{
		[outlineView setDisplayMode:[[filter objectForKey:@"displayMode"] intValue]];
	} else {
		[outlineView setDisplayMode:PAListMode];
	}
	
	[outlineView saveSelection];
	[outlineView reloadData];
	[outlineView restoreSelection];
	
	// Scrolling - if item is an array, it handles scrolling itself
	if(![[outlineView itemAtRow:[outlineView selectedRow]] isKindOfClass:[NSArray class]])
	{
		if([outlineView selectedRow])
		{
			[outlineView scrollRowToVisible:[outlineView selectedRow]];
		} else {
			[outlineView scrollPoint:NSZeroPoint];
		}
	} else {
		[[outlineView responder] scrollToVisible];
	}
	
	[[self window] makeFirstResponder:outlineView];
}


#pragma mark Drawing
- (void)drawRect:(NSRect)aRect
{
	// Draw background
	NSImage *backgroundImage = [NSImage imageNamed:@"BlueGradient24"];
	
	[backgroundImage setFlipped:YES];
	[backgroundImage setScalesWhenResized:YES];
	
	NSRect imageRect;
	imageRect.origin = NSZeroPoint;
	imageRect.size = [backgroundImage size];
	
	NSRect dirtyRect = [self bounds];
	dirtyRect.origin.x = aRect.origin.x;
	dirtyRect.size.width = aRect.size.width;
		
	[backgroundImage drawInRect:dirtyRect fromRect:imageRect operation:NSCompositeCopy fraction:1.0];

	// Super
	[super drawRect:aRect];
}


#pragma mark Misc
- (BOOL)isFlipped
{
	return YES;
}

@end
