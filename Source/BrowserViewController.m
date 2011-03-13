//
//  BrowserViewController.m
//  punakea
//
//  Created by Johannes Hoffart on 27.06.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "BrowserViewController.h"
#import "PATagCloud.h"


CGFloat const SPLITVIEW_PANEL_MIN_HEIGHT = 150.0;


@interface BrowserViewController (PrivateAPI)

- (void)tagsHaveChanged;

- (void)setDisplayTags:(NSMutableArray *)someTags filterTags:(BOOL)flag;

- (NSMutableArray*)visibleTags;
- (void)setVisibleTags:(NSMutableArray*)otherTags;
- (void)clearVisibleTags;

- (void)updateTagCloudDisplayMessage;

- (NSString*)searchFieldString;
- (void)resetSearchFieldString;
- (void)searchFieldStringHasChanged;

- (void)negatedTagButtonClicked:(PATagButton*)button;

- (void)setMainController:(PABrowserViewMainController*)aController;

- (void)filterTags:(NSArray*)someTags;
- (NSArray*)allFilters;
- (PAStringFilter*)activeStringFilter;
- (NSArray*)activeContentTypeFiltersForIdentifiers:(NSArray*)identifiers;
- (void)contentTypeFilterUpdate:(NSNotification*)notification;

- (void)updateSortDescriptor;

- (NSInteger)nextID;

@end

@implementation BrowserViewController

#pragma mark init + dealloc
- (id)init
{
	if (self = [super init])
	{
		tags = [NNTags sharedTags];
				
		filterEngineOpQueue = [[NSOperationQueue alloc] init];
		
		searchFieldString = [[NSMutableString alloc] init];
			
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
		
		[NSBundle loadNibNamed:@"BrowserView" owner:self];
	}
	return self;
}

- (void)awakeFromNib
{
	[splitView setAutosaveName:@"PASplitView Configuration BrowserSplitView" defaults:@"0 0 200 200 0 0 0 200 200 0"];
	
	[self showResults];
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
	[filterEngineOpQueue release];
	[searchFieldString release];
	[super dealloc];
}

#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object 
                        change:(NSDictionary *)change
                       context:(void *)context
{
	if ([keyPath isEqual:@"values.TagCloud.SortKey"])
	{
		sortKey = [[[NSUserDefaultsController sharedUserDefaultsController] valueForKeyPath:@"values.TagCloud.SortKey"] integerValue];
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
	
	[self searchFieldStringHasChanged];
}

- (void)setSearchField:(NSSearchField*)aSearchField
{
	searchField = aSearchField;
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
	[self setDisplayTags:someTags filterTags:YES];
}

- (void)setDisplayTags:(NSMutableArray *)someTags filterTags:(BOOL)flag
{
	// empty visibleTags
	[self clearVisibleTags];
	
	// remember active tags
	[activeTags release];
	activeTags = [someTags retain];
	
	if (flag)
	{
		// start filtering
		[self filterTags:activeTags];
	}
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

- (NSMenu *)tagButtonContextualMenu
{
	return tagButtonContextualMenu;
}

- (PATagCloud *)tagCloud
{
	return tagCloud;
}

- (NSArray *)allTags
{
	return [tags tags];
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
	else if ([[NSCharacterSet alphanumericCharacterSet] characterIsMember:key]) 
	{
		// only add to searchFieldString if there are any tags, otherwise do nothing
		NSMutableString *tmpSearchFieldString = [searchFieldString mutableCopy];
		[tmpSearchFieldString appendString:[event charactersIgnoringModifiers]];
		
		[self setSearchFieldString:tmpSearchFieldString];
	}
	else
	{
		// forward unhandled events
		[[self nextResponder] keyDown:event];
	}
}

- (IBAction)setSearchTypeFrom:(NSMenuItem *)menuItem
{
    PASearchType searchType = [menuItem tag];
	
	// update prefs
	[[NSUserDefaults standardUserDefaults] setInteger:searchType forKey:@"General.Search.Type"];
		
	// update search field appearance -
	// set all to off and menuItem to on
	NSMenu *searchTypeMenu = [menuItem menu];
	
	for (NSMenuItem *item in [searchTypeMenu itemArray]) {
		[item setState:NSOffState];
	}
	
	[menuItem setState:NSOnState];
	
	// update search if there currently is a searchFieldString	
	if ([searchFieldString length] > 0) {
		[self searchFieldStringHasChanged];	
	}
}

/** 
 Search field delegate
 */
- (void)controlTextDidChange:(NSNotification *)aNotification
{
	NSTextView *fe = [[aNotification userInfo] objectForKey:@"NSFieldEditor"];
	[self setSearchFieldString:[fe string]];
}	

- (void)searchFieldStringHasChanged
{
	[self clearVisibleTags];
	[searchField setStringValue:searchFieldString];
	[self filterTags:activeTags];
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
	// check if required objects are available
	if ([notification userInfo] == nil)
	{
		lcl_log(lcl_cglobal, lcl_vError, @"UserInfo not available");
		return;
	} 
	
	// everything is there, do the work
	NSString *changeOperation = [[notification userInfo] objectForKey:NNTagOperation];

	// if there are any selected tags, every tag operation is ignored
	// new/removed related tags will show up because of live update!
	if ([[self mainController] isKindOfClass:[PAResultsViewController class]])
	{
		if  ([[(PAResultsViewController*)mainController selectedTags] count] > 0)
			return;
	}
	
	// not updating on tag use count increase, because tag cloud would flicker too much
	// when editing tags
	if (![changeOperation isEqualTo:NNTagClickIncrementOperation] &&
		![changeOperation isEqualTo:NNTagUseChangeOperation])
	{
		// clicks are ignored, as they are (normally)
		// causing the displayed tags to change
		[self performSelectorOnMainThread:@selector(setDisplayTags:)
							   withObject:[tags tags]
							waitUntilDone:NO];
	}
}

#pragma mark tag filtering
- (void)filterTags:(NSArray*)someTags
{
	filterEngineIsWorking = YES;
		
	// cancel active filter engine (if one is active)
	[filterEngineOpQueue cancelAllOperations];
	
	NNFilterEngine *filterEngineOp = [[NNFilterEngine alloc] initWithFilterObjects:someTags
														 filters:[self allFilters]
														delegate:self];
	
	[filterEngineOpQueue addOperation:filterEngineOp];
	[filterEngineOp release];

	// empty cloud and show progress in the UI
	[self setVisibleTags:[NSArray array]];
	NSString *desc = NSLocalizedStringFromTable(@"PROGRESS_GATHERING_TAGS", @"Global", nil);
	[[[[NSApplication sharedApplication] delegate] browserController] startProgressAnimationWithDescription:desc];
}

/*
 This may be called from a different thread - be sure to internal call stuff
 on main thread
 */
- (void)filterEngineFilteredObjects:(NSArray*)objects
{
	[self setVisibleTags:[NSMutableArray arrayWithArray:objects]];
}

- (NSArray*)allFilters
{
	NSMutableArray *allFilters = [NSMutableArray array];
	
	PAStringFilter *activeStringFilter = [self activeStringFilter];
	
	if (activeStringFilter != nil)
	{
		[allFilters addObject:activeStringFilter];
	}
	
	[allFilters addObjectsFromArray:[self activeContentTypeFiltersForIdentifiers:[self contentTypeFilterIdentifiers]]];
				
	return allFilters;
}

- (void)filterEngineFinishedFiltering:(NSArray*)objects
{	
	filterEngineIsWorking = NO;
	
	[[[[NSApplication sharedApplication] delegate] browserController] stopProgressAnimation];
		
	[self setVisibleTags:[NSMutableArray arrayWithArray:objects]];
	
	[self updateTagCloudDisplayMessage];
			
	// TODO workaround for missing thumbs/icons
	[self performSelector:@selector(reloadView)
			   withObject:nil
			   afterDelay:0.2];
}

- (void)contentTypeFilterUpdate:(NSNotification*)notification
{
	[self showResults];
	
	NSString *contentType = [[notification userInfo] objectForKey:@"contentType"];
	[self setContentTypeFilterIdentifiers:[NSArray arrayWithObject:contentType]];
		
	[self filterTags:activeTags];
}

- (PAStringFilter*)activeStringFilter
{
	PAStringFilter *newFilter = nil;
	
	if ([searchFieldString length] > 0)
	{
		NSString *decomposedSearchString = [searchFieldString decomposedStringWithCanonicalMapping];
		
		PASearchType searchType = [[NSUserDefaults standardUserDefaults] integerForKey:@"General.Search.Type"];
		
		switch (searchType) {
			case PATagPrefixSearchType:
				newFilter = [[[PAStringPrefixFilter alloc] initWithFilter:decomposedSearchString] autorelease];
				break;
			case PATagSearchType:
				newFilter = [[[PAStringFilter alloc] initWithFilter:decomposedSearchString] autorelease];
				break;
			default:
				NSLog(@"Must not happen - FIXME");
				break;
		}
	}
	
	return newFilter;
}

- (NSArray*)activeContentTypeFiltersForIdentifiers:(NSArray*)identifiers
{
	NSMutableArray *filters = [NSMutableArray array];
	
	// create and add content type filters	
	for (NSString *contentTypeIdentifier in identifiers)
	{
		PAContentTypeFilter *filter = [PAContentTypeFilter filterWithContentType:contentTypeIdentifier];
		[filters addObject:filter];
	}
	
	return filters;
}

#pragma mark actions
- (void)reloadView
{
	[[self view] setNeedsDisplay:YES];
}

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
		else if (!filterEngineIsWorking && ([self allFilters] > 0))
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
	
	// emptry search field	
	[self resetSearchFieldString];
	
	// reset maincontroller
	[mainController reset];
	
	// reset selected tag
	[self displaySelectedTag:nil];
	
	// display all tags
	[self setDisplayTags:[tags tags] filterTags:NO];
	[self setVisibleTags:[tags tags]];
}

- (void)reloadData
{
	sortKey = [[NSUserDefaults standardUserDefaults] integerForKey:@"TagCloud.SortKey"];
	[self updateSortDescriptor];
	NSMutableArray *currentVisibleTags = [visibleTags mutableCopy];
	[self setVisibleTags:currentVisibleTags];
	[currentVisibleTags release];
}


#pragma mark Contextual Menu for Tag Buttons of Tag Cloud
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	if ([menuItem action] == @selector(includeTag:) ||
		[menuItem action] == @selector(excludeTag:))
	{
		// Disable menu items for MANAGE_TAGS view	
		if (mainController &&
			![mainController isKindOfClass:[PAResultsViewController class]])
		{
			return NO;
		}
	}
	
	return YES;
}

- (IBAction)includeTag:(id)sender
{
	NNTag *tag = (NNTag *)[(NSMenuItem *)sender representedObject];
	
	[tagCloud selectTag:tag];
	[self tagButtonClicked:[tagCloud activeButton]]; 
}

- (IBAction)excludeTag:(id)sender
{
	NNTag *tag = (NNTag *)[(NSMenuItem *)sender representedObject];
	
	[tagCloud selectTag:tag];
	[self negatedTagButtonClicked:[tagCloud activeButton]]; 	
}

- (IBAction)editTag:(id)sender
{
	NNTag *tag = (NNTag *)[(NSMenuItem *)sender representedObject];
	
	[tagCloud selectTag:tag];
	
	PATagButton *tagButton = [[tagCloud activeButton] retain];	// Pointer will be lost when navigating away in cloud
	
	[[NSApp delegate] goToManageTags:self];						// Navigate to manage tags
	
	[self tagButtonClicked:tagButton];							// Select tag
	
	[tagButton release];										// Free pointer
}

#pragma mark Split View
- (CGFloat)splitView:(NSSplitView *)sender constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)offset
{
	return SPLITVIEW_PANEL_MIN_HEIGHT;
}

- (CGFloat)splitView:(NSSplitView *)sender constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)offset
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

#pragma mark TagCloud DataSource

- (NSUInteger)numberOfTagsInTagCloud:(PATagCloud*)aTagCloud
{
	return [visibleTags count];
}

- (NNTag*)tagCloud:(PATagCloud*)aTagCloud tagForIndex:(NSUInteger)i
{
	return [visibleTags objectAtIndex:i];
}

- (BOOL)tagCloud:(PATagCloud*)aTagCloud containsTag:(NNTag*)aTag
{
	return [visibleTags containsObject:aTag];
}

- (NNTag*)currentBestTagInTagCloud:(PATagCloud*)aTagCloud
{
	NSEnumerator *e = [visibleTags objectEnumerator];
	NNTag *tag;
	NNTag *maxTag;
			
	if (tag = [e nextObject])
		maxTag = tag;
		
	while (tag = [e nextObject])
	{
		if ([tag absoluteRating] > [maxTag absoluteRating])
			maxTag = tag;
	}	
	
	return maxTag;
}

#pragma mark TagCloud Delegate

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

- (BOOL)isWorking
{
	if (!mainController || ![mainController isWorking])
		return NO;
	else
		return YES;
}

- (void)makeControlledViewFirstResponder
{
	[[[self view] window] makeFirstResponder:[mainController dedicatedFirstResponder]];
}

- (IBAction)tagButtonClicked:(PATagButton*)button
{
	// Make tagcloud first responder on click of a tag button
	if([[tagCloud window] firstResponder] != tagCloud)
		[[tagCloud window] makeFirstResponder:tagCloud];
	
	if (mainController && [mainController isKindOfClass:[PAResultsViewController class]])
		[self resetSearchFieldString];
	
	NNTag *tag = [button genericTag];
	[mainController handleTagActivation:tag];
}

- (void)negatedTagButtonClicked:(PATagButton*)button
{
	// Make tagcloud first responder on click of a tag button
	if([[tagCloud window] firstResponder] != tagCloud)
		[[tagCloud window] makeFirstResponder:tagCloud];
	
	if (mainController && [mainController isKindOfClass:[PAResultsViewController class]])
		[self resetSearchFieldString];
	
	NNTag *tag = [button genericTag];
	[mainController handleTagNegation:tag];
}

@end
