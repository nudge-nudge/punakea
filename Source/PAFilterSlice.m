//
//  PAFilterSlice.m
//  punakea
//
//  Created by Daniel on 31.07.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "PAFilterSlice.h"
#include <tgmath.h>


NSSize const FILTERSLICE_PADDING = {10,5};
NSUInteger const FILTERSLICE_BUTTON_SPACING = 2;


@interface PAFilterSlice (PrivateAPI)

- (void)setupButtons;
- (void)update;
- (void)performUpdate;
- (void)updateButtons;

@end


@implementation PAFilterSlice

#pragma mark Init + Dealloc
- (id)initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
	if(self)
	{		
		buttons = [[NSMutableArray alloc] init];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
		                                         selector:@selector(update)
												     name:NNQueryDidUpdateNotification
												   object:[controller query]];
		[[NSNotificationCenter defaultCenter] addObserver:self
		                                         selector:@selector(update)
												     name:NNQueryDidFinishGatheringNotification
												   object:[controller query]];
		[[NSNotificationCenter defaultCenter] addObserver:self
		                                         selector:@selector(update)
												     name:NNQueryDidResetNotification
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
	for(NSUInteger i = 0; i < 10; i++)
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
				[filter setObject:[NSNumber numberWithInteger:PAThumbnailMode] forKey:@"displayMode"];
				[filter setObject:[NSArray arrayWithObject:@"PDF"] forKey:@"filterValues"];
				[filter setObject:@"kMDItemContentTypeTree" forKey:@"filterBundlingAttribute"];
				break;
			case 5:		// IMAGES
				[filter setObject:@"IMAGES" forKey:@"title"];
				[filter setObject:[NSNumber numberWithInteger:PAThumbnailMode] forKey:@"displayMode"];
				[filter setObject:[NSArray arrayWithObject:@"IMAGES"] forKey:@"filterValues"];
				[filter setObject:@"kMDItemContentTypeTree" forKey:@"filterBundlingAttribute"];
				break;
			case 6:		// PRESENTATIONS
				[filter setObject:@"PRESENTATIONS" forKey:@"title"];
				[filter setObject:[NSArray arrayWithObject:@"PRESENTATIONS"] forKey:@"filterValues"];
				[filter setObject:@"kMDItemContentTypeTree" forKey:@"filterBundlingAttribute"];
				break;
			case 7:		// CONTACT
				[filter setObject:@"CONTACT" forKey:@"title"];
				[filter setObject:[NSArray arrayWithObject:@"CONTACT"] forKey:@"filterValues"];
				[filter setObject:@"kMDItemContentTypeTree" forKey:@"filterBundlingAttribute"];
				break;
			case 8:		// BOOKMARKS
				[filter setObject:@"BOOKMARKS" forKey:@"title"];
				[filter setObject:[NSArray arrayWithObject:@"BOOKMARKS"] forKey:@"filterValues"];
				[filter setObject:@"kMDItemContentTypeTree" forKey:@"filterBundlingAttribute"];
				break;
			case 9:		// FOLDERS
				[filter setObject:@"DIRECTORIES" forKey:@"title"];
				[filter setObject:[NSArray arrayWithObject:@"DIRECTORIES"] forKey:@"filterValues"];
				[filter setObject:@"kMDItemContentTypeTree" forKey:@"filterBundlingAttribute"];
				break;

		}
		
		// Determine button's title
		NSString *title = [[NSBundle bundleWithIdentifier:@"eu.nudgenudge.nntagging"] localizedStringForKey:[filter objectForKey:@"title"]
																									  value:[filter objectForKey:@"title"]
																									  table:@"MDSimpleGrouping"];
		if(!title) title = @"All";
		[button setTitle:title];
		[button sizeToFit];
		
		// Add button to array
		[buttons addObject:button];
		[button release];
		
//		// Draw sorting an grouping buttons
//		groupingButton = [[NSButton alloc] initWithFrame:[self frame]];
//		[groupingButton setTitle:@"Group"];
//		//[groupingButton setBezelStyle:NSDisclosureBezelStyle];
//		[groupingButton setButtonType:NSPushOnPushOffButton];
//		
//		
//		[self addSubview:groupingButton];
//		NSRect buttonFrame = [groupingButton frame];
//		buttonFrame.origin.x = 200;
//		buttonFrame.origin.y = FILTERSLICE_PADDING.height;
////		buttonFrame.size.width = 50;
////		buttonFrame.size.height = 20;
//		[groupingButton setFrame:buttonFrame];
	}
}

- (void)update
{
	// Give query some time to gather results. So we may try to keep the current filter selection.
	[self performSelector:@selector(performUpdate)
			   withObject:self
			   afterDelay:0.2];
}

- (void)performUpdate
{
	// Break if view is not available
	if (![self canDraw])
		return;	
	
	// Show or hide buttons
	[self updateButtons];
	
	PAButton *selectedButton = nil;
	
	for(PAButton *button in buttons)
	{
		if([button isHighlighted])
		{
			selectedButton = button;
			break;
		}
	}
	
	if(!selectedButton)
	{
		// Select the ALL tab by default
		selectedButton = [buttons objectAtIndex:0];
	}
	
	// Perform filtering
	[self buttonClick:selectedButton];
}

- (void)updateButtons
{	
	CGFloat x = FILTERSLICE_PADDING.width;

	/*NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *spotlightDict = [defaults persistentDomainForName:@"com.apple.spotlight"];
	
	NSMutableArray *orderedItems = [[spotlightDict objectForKey:@"orderedItems"] mutableCopy];*/
	
	for (PAFilterButton *button in buttons)
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
			// Adjust button's frame and make visible if needed
			
			NSRect buttonFrame = [button frame];
			x += ceil(buttonFrame.size.width) + FILTERSLICE_BUTTON_SPACING;
		
			if([button superview] != self)
				[self addSubview:button];
			
			[button setFrame:frame];
		}
		else
		{
			// Deselect and hide button			
			
			[button highlight:NO];			
			
			if([button superview] == self) 
				[button removeFromSuperview];
		}
	}
	
	[self setNeedsDisplay:YES];
}

- (void)buttonClick:(id)sender
{
	//[[self window] makeFirstResponder:self];

	// Highlight active filter button
	for (NSButton *button in buttons)
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
	
	NNQuery *query = [controller query];
	NSDictionary *filter = [sender filter];
	
	// Bundlings attributes that we set here need to be wrapped into an NNQueryItem in 
	// NNQuery's bundleResults:byAttributes:objectWrapping!! Only a few are there yet! TODO!
	if([[buttons objectAtIndex:0] isEqualTo:sender])
	{
		[query filterResults:NO 
				 usingValues:nil
		forBundlingAttribute:nil
	   newBundlingAttributes:nil];
	} else {
		[query filterResults:YES
				 usingValues:[filter objectForKey:@"filterValues"]
		forBundlingAttribute:[filter objectForKey:@"filterBundlingAttribute"]
	   newBundlingAttributes:[filter objectForKey:@"filterNewBundlingAttributes"]];
	}
	
	// Set display mode
	if([filter objectForKey:@"displayMode"])
	{
		[outlineView setDisplayMode:[[filter objectForKey:@"displayMode"] integerValue]];
	} else {
		[outlineView setDisplayMode:PAListMode];
	}
	
	[outlineView reloadData];
	
	// Scrolling - if item is an array, it handles scrolling itself
	/*if(![[outlineView itemAtRow:[outlineView selectedRow]] isKindOfClass:[NSArray class]])
	{
		if([outlineView selectedRow])
		{
			[outlineView scrollRowToVisible:[outlineView selectedRow]];
		} else {
			[outlineView scrollPoint:NSZeroPoint];
		}
	} else {
		[[outlineView responder] scrollToVisible];
	}*/
	[outlineView scrollPoint:NSZeroPoint];
	
	// Focus outlineView or tag cloud, depending on number of selected tags
	/*if ([[[controller query] tags] count] > 0)
		[[self window] makeFirstResponder:outlineView];
	else
		[[self window] makeFirstResponder:[[[[[NSApplication sharedApplication] delegate] browserController] browserViewController] tagCloud]]; */
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
	
	// Draw bottom border
	NSRect bounds = [self bounds];		
	
	NSBezierPath *path = [NSBezierPath bezierPath];
	[path moveToPoint:NSMakePoint(0, bounds.size.height)];
	[path lineToPoint:NSMakePoint(bounds.size.width, bounds.size.height)];
	[path closePath];
	[[NSColor grayColor] set];	
	[path stroke];

	// Super
	[super drawRect:aRect];
}


#pragma mark Misc
- (BOOL)isFlipped
{
	return YES;
}

@end
