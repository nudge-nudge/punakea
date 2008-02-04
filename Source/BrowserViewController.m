//
//  BrowserViewController.m
//  punakea
//
//  Created by Johannes Hoffart on 27.06.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "BrowserViewController.h"
#import "PATagCloud.h"


float const SPLITVIEW_PANEL_MIN_HEIGHT = 150.0;


@interface BrowserViewController (PrivateAPI)

- (void)tagsHaveChanged;

- (NSMutableArray*)visibleTags;
- (void)setVisibleTags:(NSMutableArray*)otherTags;
- (void)clearVisibleTags;

- (NNTag*)currentBestTag;
- (void)setCurrentBestTag:(NNTag*)otherTag;

- (void)updateTagCloudDisplayMessage;

- (NSString*)searchFieldString;
- (void)resetSearchFieldString;
- (void)searchFieldStringHasChanged;

- (void)setMainController:(PABrowserViewMainController*)aController;

- (void)setActivePrefixFilter:(PAStringPrefixFilter*)filter;
- (PAStringPrefixFilter*)activePrefixFilter;

- (void)filterTags:(NSArray*)someTags;
- (void)setupFilterEngine;
- (void)filterTags;
- (void)setFilterEngineConnection:(NSConnection*)conn;
- (NSConnection*)filterEngineConnection;

- (void)updateSortDescriptor;

- (int)nextID;

@end



@implementation BrowserViewController

#pragma mark init + dealloc
- (id)init
{
	if (self = [super init])
	{
		tags = [NNTags sharedTags];
				
		// needs to be setup before tags can be displayed
		// cannot be done here or in awakeFromNib because of wrong
		// order, self needs to be available already
		filterEngine = nil;
		
		searchFieldString = [[NSMutableString alloc] init];
		
		[self addObserver:self forKeyPath:@"searchFieldString" options:nil context:NULL];
	
		sortKey = [[NSUserDefaults standardUserDefaults] integerForKey:@"TagCloud.SortKey"];
		[self updateSortDescriptor];
		
		[[NSUserDefaultsController sharedUserDefaultsController] addObserver:self 
																  forKeyPath:@"values.TagCloud.SortKey" 
																	 options:0 
																	 context:NULL];
		
		[[NSUserDefaultsController sharedUserDefaultsController] addObserver:self 
																  forKeyPath:@"values.TagCloud.ClickCountWeight" 
																	 options:0 
																	 context:NULL];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(tagsHaveChanged:) 
													 name:NNTagsHaveChangedNotification
												   object:tags];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(contentTypeFilterUpdate:)
													 name:PAContentTypeFilterUpdate
												   object:nil];
		
		filterEngine = [[NNFilterEngine alloc] init];
		activePrefixFilter = nil;
		
		[NSBundle loadNibNamed:@"BrowserView" owner:self];
	}
	return self;
}

- (void)awakeFromNib
{
	[splitView setAutosaveName:@"PASplitView Configuration BrowserSplitView" defaults:@"0 0 200 200 0 0 0 200 200 0"];
	
	[self showResults];
	[[[self view] window] setInitialFirstResponder:tagCloud];
}	

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[NSUserDefaultsController sharedUserDefaultsController] removeObserver:self
																 forKeyPath:@"values.TagCloud.SortKey"];
	[[NSUserDefaultsController sharedUserDefaultsController] removeObserver:self
																 forKeyPath:@"values.TagCloud.ClickCountWeight"];
	
	[sortDescriptor release];
	[mainController release];
	[visibleTags release];
	[activePrefixFilter release];
	[filterEngineConnection release];
	[filterEngine release];
	[searchFieldString release];
	[super dealloc];
}

#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object 
                        change:(NSDictionary *)change
                       context:(void *)context
{
	if ([keyPath isEqualToString:@"searchFieldString"])
	{
		[self searchFieldStringHasChanged];
	}
	else if ([keyPath isEqual:@"values.TagCloud.SortKey"])
	{
		sortKey = [[[NSUserDefaultsController sharedUserDefaultsController] valueForKeyPath:@"values.TagCloud.SortKey"] intValue];
		[self updateSortDescriptor];
		NSMutableArray *currentVisibleTags = [visibleTags mutableCopy];
		[self setVisibleTags:currentVisibleTags];
		[currentVisibleTags release];
	}
	else if ([keyPath isEqualToString:@"values.TagCloud.ClickCountWeight"])
	{
		[self reset];
	}
}

#pragma mark accessors
- (NNTag*)currentBestTag
{
	return currentBestTag;
}

- (void)setCurrentBestTag:(NNTag*)otherTag
{
	[otherTag retain];
	[currentBestTag release];
	currentBestTag = otherTag;
}

- (NSString*)searchFieldString
{
	return searchFieldString;
}

- (void)setSearchFieldString:(NSString*)string
{
	if (!string)
		string = @"";
	
	[searchFieldString release];
	searchFieldString = [string mutableCopy];
}

- (PABrowserViewMainController*)mainController
{
	return mainController;
}

- (void)setMainController:(PABrowserViewMainController*)aController
{
	[aController retain];
	[mainController release];

	mainController = aController;
	
	[mainController setDelegate:self];
	[mainController setNextResponder:self];
	
	// remove all subviews
	NSArray *subviews = [controlledView subviews];
	NSEnumerator *e = [subviews objectEnumerator];
	NSView *subview;

	while (subview = [e nextObject])
	{
		[subview removeFromSuperview];
	}
	
	[controlledView addSubview:[mainController view]];
}

- (NSView*)controlledView
{
	return controlledView;
}

- (BOOL)isWorking
{
	if (!mainController || ![mainController isWorking])
		return NO;
	else
		return YES;
}

- (void)setActivePrefixFilter:(PAStringPrefixFilter*)filter
{
	[filter retain];
	[activePrefixFilter release];
	activePrefixFilter = filter;
}

- (PAStringPrefixFilter*)activePrefixFilter
{
	return activePrefixFilter;
}

- (NSMutableArray*)visibleTags;
{
	return visibleTags;
}

- (void)setVisibleTags:(NSMutableArray*)otherTags
{
	[visibleTags release];
			
	NSArray *sortedArray = [otherTags sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	visibleTags = [sortedArray mutableCopy];
		
	[self updateTagCloudDisplayMessage];
	
	[tagCloud reloadData];
	
	// if find-as-you-type is active, select upper left tag
	// this way the tag can be activated directly by clicking enter
	if ([searchFieldString length] > 0)
		[tagCloud selectUpperLeftButton];
}

- (void)clearVisibleTags
{
	[visibleTags release];
	visibleTags = [[NSMutableArray alloc] init];
	
	[tagCloud reloadData];
}

- (void)setDisplayTags:(NSMutableArray*)someTags
{
	// empty visibleTags
	[self clearVisibleTags];
	
	// start filtering
	[self filterTags:someTags];
}

- (void)resetDisplayTags
{
	[self setDisplayTags:[tags tags]];
}

- (void)displaySelectedTag:(NNTag*)tag
{
	[tagCloud selectTag:tag];
}

- (void)removeActiveTagButton
{
	[tagCloud removeActiveTagButton];
}

- (PATagCloud *)tagCloud
{
	return tagCloud;
}

- (NSArray *)allTags
{
	return [tags tags];
}

- (NSArray*)activeContentTypeFilters
{
	return activeContentTypeFilters;
}

- (void)setActiveContentTypeFilters:(NSArray*)filters
{
	[self clearVisibleTags];
	
	[filters retain];
	[activeContentTypeFilters release];
	activeContentTypeFilters = filters;
		
	// adjust filterengine
	// remove old content type filters
	NSEnumerator *oldFiltersEnumerator = [[filterEngine filters] objectEnumerator];
	NNObjectFilter *filter;
	
	while (filter = [oldFiltersEnumerator nextObject])
	{
		if ([filter isKindOfClass:[PAContentTypeFilter class]])
		{
			[filterEngine removeFilter:filter];
		}
	}
	
	// add new filters
	NSEnumerator *newFilterEnumerator = [filters objectEnumerator];
	
	while (filter = [newFilterEnumerator nextObject])
	{
		[filterEngine addFilter:filter];
	}
}

- (NSArray*)contentTypeFilterIdentifiers
{
	return contentTypeFilterIdentifiers;
}

- (void)setContentTypeFilterIdentifiers:(NSArray*)identifiers
{
	[contentTypeFilterIdentifiers release];
	contentTypeFilterIdentifiers = [identifiers retain];
}

#pragma mark tag stuff
- (IBAction)tagButtonClicked:(id)sender
{
	// Make tagcloud first responder on click of a tag button
	if([[tagCloud window] firstResponder] != tagCloud)
		[[tagCloud window] makeFirstResponder:tagCloud];
	
	if (mainController && [mainController isKindOfClass:[PAResultsViewController class]])
		[self resetSearchFieldString];
	
	NNTag *tag = [sender genericTag];
	[mainController handleTagActivation:tag];
}

#pragma mark typeAheadFind
- (void)resetSearchFieldString
{
	if ([searchFieldString length] > 0)
		[self setSearchFieldString:@""];
}

#pragma mark events
- (void)keyDown:(NSEvent*)event 
{
	// get the pressed key
	unichar key = [[event charactersIgnoringModifiers] characterAtIndex:0];
	
	// create character set for testing
	NSCharacterSet *alphanumericCharacterSet = [NSCharacterSet alphanumericCharacterSet];
	
	if (key == NSDeleteCharacter) 
	{
		// if searchFieldString has any content (i.e. user is using type-ahead-find), delete last char
		if ([searchFieldString length] > 0)
		{
			NSString *tmpSearchFieldString = [searchFieldString substringToIndex:[searchFieldString length]-1];
			[self setSearchFieldString:tmpSearchFieldString];
		}
		else if ([mainController isKindOfClass:[PAResultsViewController class]])
		// else delete the last selected tag (if resultsview is active)
		{
			[(PAResultsViewController*)mainController removeLastTag];
		}
	}
	else if ([alphanumericCharacterSet characterIsMember:key]) 
	{
		// only add to searchFieldString if there are any tags, otherwise do nothing
		NSMutableString *tmpsearchFieldString = [searchFieldString mutableCopy];
		[tmpsearchFieldString appendString:[event charactersIgnoringModifiers]];
		
		[self setSearchFieldString:tmpsearchFieldString];
		[tmpsearchFieldString release];
	}
	else
	{
		// forward unhandled events
		[[self nextResponder] keyDown:event];
	}
}

- (void)searchFieldStringHasChanged
{
	[self clearVisibleTags];
	
	// if searchFieldString has any content, display tags with corresponding prefix
	// else display all tags
	if ([searchFieldString length] > 0)
	{
		// remove old filter
		if (activePrefixFilter)
		{
			[filterEngine removeFilter:[self activePrefixFilter]];
		}
		PAStringPrefixFilter *newFilter = [[[PAStringPrefixFilter alloc] initWithFilterPrefix:searchFieldString] autorelease];
		[filterEngine addFilter:newFilter];
		[self setActivePrefixFilter:newFilter];
		
		filterEngineIsWorking = YES;
	}
	else
	{
		if (activePrefixFilter) 
		{
			[filterEngine removeFilter:[self activePrefixFilter]];
		}		
		[self setActivePrefixFilter:nil];
	}
}

- (void)controlledViewHasChanged
{	
	// resize controlledView to content subview
	NSView *subview = [[controlledView subviews] objectAtIndex:0];
	NSRect subviewFrame = [subview frame];
	NSRect oldFrame = [controlledView frame];
	[subview setFrame:NSMakeRect(0.0,0.0,oldFrame.size.width,oldFrame.size.height)];
	[controlledView setFrame:NSMakeRect(0.0,0.0,oldFrame.size.width,subviewFrame.size.height)];
	[splitView adjustSubviews];
}


#pragma mark Notifications
- (void)tagsHaveChanged:(NSNotification*)notification
{
	NSString *changeOperation = [[notification userInfo] objectForKey:NNTagOperation];
	
	// not updating on tag use count increase, because tag cloud would flicker too much
	// when editing tags
		
//		[NSObject cancelPreviousPerformRequestsWithTarget:self
//												 selector:@selector(setVisibleTags:)
//												   object:[tags tags]];
//		[self performSelector:@selector(setDisplayTags:)
//				   withObject:[tags tags]
//				   afterDelay:0.5];
	if ([changeOperation isNotEqualTo:NNTagClickIncrementOperation] &&
		[changeOperation isNotEqualTo:NNTagUseChangeOperation])
	{
		// clicks are ignored, as they are (normally)
		// causing the displayed tags to change
		[self setDisplayTags:[tags tags]];
	}
}

- (void)contentTypeFilterUpdate:(NSNotification*)notification
{
	[self showResults];
	
	NSString *contentType = [[notification userInfo] objectForKey:@"contentType"];
	
	[self setContentTypeFilterIdentifiers:[NSArray arrayWithObject:contentType]];
	
	NNObjectFilter *filter = [PAContentTypeFilter filterWithContentType:contentType];
	[self setActiveContentTypeFilters:[NSArray arrayWithObject:filter]];
}


#pragma mark tag filtering
- (void)filterTags:(NSArray*)someTags
{
	filterEngineIsWorking = YES;
	[filterEngine setObjects:someTags];
	
	[filterEngine startWithServer:self];
}

- (void)filteringStarted
{
	NSString *desc = NSLocalizedStringFromTable(@"PROGRESS_GATHERING_TAGS", @"Global", nil);
	[[[[NSApplication sharedApplication] delegate] browserController] startProgressAnimationWithDescription:desc];
}

- (void)filteringFinished
{
	filterEngineIsWorking = NO;
	
	[[[[NSApplication sharedApplication] delegate] browserController] stopProgressAnimation];
	
	[self updateTagCloudDisplayMessage];
	
	// TODO workaround for missing thumbs/icons
	[self performSelector:@selector(reloadView)
			   withObject:nil
			   afterDelay:0.2];
}

- (void)reloadView
{
	[[self view] setNeedsDisplay:YES];
}

- (void)objectsFiltered
{
	[filterEngine lockFilteredObjects];
	[self setVisibleTags:[filterEngine filteredObjects]];
	[filterEngine unlockFilteredObjects];
}

- (void)removeAllFilters
{
	[self setActiveContentTypeFilters:[NSArray array]];
	[filterEngine removeFilter:[self activePrefixFilter]];
	[self setActivePrefixFilter:nil];
}


#pragma mark actions
- (void)updateTagCloudDisplayMessage
{
	// if there are no visible tags,
	// display a status message
	if ([visibleTags count] == 0)
	{
		if ([tags count] == 0)
		{
			[tagCloud setDisplayMessage:NSLocalizedStringFromTable(@"NO_TAGS",@"Tags",@"")];
		}
		else if (([searchFieldString length] > 0) && 
				 !filterEngineIsWorking && 
				 ![mainController isWorking])
		{
			// searchstring stuff
			[tagCloud setDisplayMessage:NSLocalizedStringFromTable(@"NO_TAGS_FOR_SEARCHSTRING",@"Tags",@"")];
		}
		else if (mainController && [[mainController displayMessage] isNotEqualTo:@""])
		{
			// give the mainController a chance to display a message
			[tagCloud setDisplayMessage:[mainController displayMessage]];
		}
		else if (!filterEngineIsWorking && 
				 [[filterEngine filters] count] > 0)
		{
			// no items found for content type
			[tagCloud setDisplayMessage:NSLocalizedStringFromTable(@"NO_TAGS_FOR_CONTENTTYPE",@"Tags",@"")];
		}
	}
	else
	{
		[tagCloud setDisplayMessage:@""];
	}
	
	// reload data to display message if necessary
	if ([[tagCloud displayMessage] length] > 0)
		[tagCloud reloadData];
}

- (void)searchForTags:(NSArray*)someTags
{
	// empty active content filters
	[self setContentTypeFilterIdentifiers:[NSArray array]];
	
	// reset filterEngine
	[filterEngine reset];
	
	// emptry search field	
	[self resetSearchFieldString];
	
	[self showResults];
	[[self mainController] handleTagActivations:someTags];
}

- (void)manageTags
{
	if ([[self mainController] isKindOfClass:[PATagManagementViewController class]])
	{
		return;
	}
	else
	{
		PATagManagementViewController *tmvController = [[PATagManagementViewController alloc] init];
		[self switchMainControllerTo:tmvController];
		[tmvController release];
	}
}

- (void)showResults
{
	if ([[self mainController] isKindOfClass:[PAResultsViewController class]])
	{
		return;
	}
	else
	{
		PAResultsViewController *rvController = [[PAResultsViewController alloc] init];
		[self switchMainControllerTo:rvController];
		[rvController release];
	}
}

- (void)switchMainControllerTo:(PABrowserViewMainController*)controller
{
	[self resetSearchFieldString];
	[self setDisplayTags:[tags tags]];
	[self setMainController:controller];
}

- (void)reset
{
	// empty active content filters
	[self setContentTypeFilterIdentifiers:[NSArray array]];
	
	// reset filterEngine
	[filterEngine reset];
	
	// emptry search field	
	[self resetSearchFieldString];
	
	// reset maincontroller
	[mainController reset];
	
	// display all tags
	[self setDisplayTags:[tags tags]];
}

- (void)unbindAll
{
	[self removeObserver:self forKeyPath:@"searchFieldString"];
}

- (void)makeControlledViewFirstResponder
{
	[[[self view] window] makeFirstResponder:[mainController dedicatedFirstResponder]];
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
	NSDictionary *userInfo = [aNotification userInfo];
	NSText *fieldEditor = [userInfo objectForKey:@"NSFieldEditor"];
	NSString *currentString = [fieldEditor string];
	
	if ([currentString isNotEqualTo:@""])
	{
		NSString *newString = [currentString substringToIndex:[currentString length]-1];
		[fieldEditor setString:newString];
	}
}

- (void)reloadData
{
	sortKey = [[NSUserDefaults standardUserDefaults] integerForKey:@"TagCloud.SortKey"];
	[self updateSortDescriptor];
	NSMutableArray *currentVisibleTags = [visibleTags mutableCopy];
	[self setVisibleTags:currentVisibleTags];
	[currentVisibleTags release];
}


#pragma mark drag & drop stuff
- (void)taggableObjectsHaveBeenDropped:(NSArray*)objects
{
	TaggerController *taggerController = [[TaggerController alloc] init];
	
	BOOL manageFiles = [[NSUserDefaults standardUserDefaults] boolForKey:@"ManageFiles.ManagedFolder.Enabled"];
	
	// Check if PADropManager is in alternate state
	if([[PADropManager sharedInstance] alternateState])
		manageFiles = !manageFiles;
	
	[taggerController setManageFiles:manageFiles];
	
	[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
	
	[taggerController showWindow:nil];	
	[[taggerController window] makeKeyAndOrderFront:nil];
	
	[taggerController addTaggableObjects:objects];
	
	[[PADropManager sharedInstance] setAlternateState:NO];
}


#pragma mark Split View
- (float)splitView:(NSSplitView *)sender constrainMinCoordinate:(float)proposedMin ofSubviewAt:(int)offset
{
	return SPLITVIEW_PANEL_MIN_HEIGHT;
}

- (float)splitView:(NSSplitView *)sender constrainMaxCoordinate:(float)proposedMax ofSubviewAt:(int)offset
{
	NSRect frame = [sender frame];
	return frame.size.height - SPLITVIEW_PANEL_MIN_HEIGHT;
}

#pragma mark sorting
- (void)updateSortDescriptor
{
	[sortDescriptor release];
	
	// sort otherTags accorings to userDefaults
	if (sortKey == PATagCloudNameSortKey)
	{
		sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
	}
	else if (sortKey == PATagCloudRatingSortKey)
	{
		sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"absoluteRating" ascending:NO];
	}
	else
	{
		// default to name
		sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
	}
}

@end
