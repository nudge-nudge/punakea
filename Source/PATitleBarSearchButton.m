//
//  PATitleBarSearchButton.m
//  punakea
//
//  Created by Daniel Bär on 04.12.11.
//  Copyright 2011 nudge:nudge. All rights reserved.
//

#import "PATitleBarSearchButton.h"

@implementation PATitleBarSearchButton

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self)
	{		
		expanded = NO;
		
        [self setTarget:self];
		[self setAction:@selector(showSearchField:)];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(tagsHaveChanged:) 
													 name:NNTagsHaveChangedNotification
												   object:[NNTags sharedTags]];
    }
    
    return self;
}

+ (PATitleBarSearchButton *)titleBarButton
{
	return (PATitleBarSearchButton *)[super titleBarButton];
}


#pragma mark Actions
- (void)showSearchField:(id)sender
{
	if (!expanded)
	{
		// Search button is minimized, so extend it an add the search field as a subview
		
		expanded = YES;
		
		[self addSubview:searchField];
		[searchField setAutoresizingMask:NSViewWidthSizable];
		[searchField setFrame:NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height)];

		// Forward actions to self
		[[[searchField cell] cancelButtonCell] setAction:@selector(abortSearch:)];
		[[[searchField cell] cancelButtonCell] setTarget:self];
		
		[[self animator] setFrame:NSMakeRect(self.frame.origin.x - extensionWidth,
											 self.frame.origin.y,
											 self.frame.size.width + extensionWidth,
											 self.frame.size.height)];
		
		// Make searchfield the first responder
		[[self window] performSelector:@selector(makeFirstResponder:) withObject:searchField afterDelay:[[NSAnimationContext currentContext] duration]];
	}
	else
	{
		// Search button is already extended. Just make it the first responder.
		[[self window] makeFirstResponder:searchField];
	}
}

- (void)abortSearch:(id)sender
{
	[searchField setStringValue:@""];
	[self closeSearchField:self];
}

- (void)closeSearchField:(id)sender
{
	if (expanded) {
		[[self animator] setFrame:NSMakeRect(self.frame.origin.x + extensionWidth,
											 self.frame.origin.y,
											 self.frame.size.width - extensionWidth,
											 self.frame.size.height)];
	}
	
	expanded = NO;	
	
	[searchField performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:[[NSAnimationContext currentContext] duration]];
}

- (void)selectSearchMenuItemWithTag:(NSInteger)tag
{
	// Update menu item states
	NSMenu *menu = [[searchField cell] searchMenuTemplate];
	
	for (NSMenuItem *item in [menu itemArray])
	{
		[item setState:NSOffState];
	}
	
	[[menu itemWithTag:tag] setState:NSOnState];
	
	[[searchField cell] setSearchMenuTemplate:menu];
	
	// update prefs
	[[NSUserDefaults standardUserDefaults] setInteger:tag forKey:@"General.Search.Type"];
}


#pragma mark Notifications
- (void)tagsHaveChanged:(NSNotification *)notification
{
	[self abortSearch:self];
}


#pragma mark Accessors
- (float)extensionWidth
{
	return extensionWidth;
}

- (void)setExtensionWidth:(float)aWidth
{
	extensionWidth = aWidth;
}

- (NSSearchField *)searchField
{
	return searchField;
}

- (void)setSearchField:(NSSearchField *)aSearchField
{	 
	[searchField release];
	searchField = [aSearchField retain];	
}

- (void)sizeToFit
{
	[super sizeToFit];
}

@end
