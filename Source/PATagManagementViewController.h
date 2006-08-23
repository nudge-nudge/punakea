//
//  PATagManagementViewController.h
//  punakea
//
//  Created by Johannes Hoffart on 13.07.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PAViewController.h"

#import "PATagger.h"
#import "PAQuery.h"

/**
tag management. at the moment the tags are not in sync with PATags, but
 changes are passed on to it (changes in PATags are not passed to displayTags)
 */
@interface PATagManagementViewController : PAViewController {
	IBOutlet NSTableView *tableView;
	
	PATagger *tagger;
	PATags *tags;
	NSMutableArray *displayTags;
	
	NSNotificationCenter *nc;
	
	PAQuery *query;
	PATag *editedTag; /**< needed for table editing */
	
	BOOL deleting;
	BOOL renaming;
}

- (id)initWithNibName:(NSString*)nibName;

- (BOOL)isDeleting;
- (void)setDeleting:(BOOL)flag;
- (BOOL)isRenaming;
- (void)setRenaming:(BOOL)flag;

- (NSMutableArray*)displayTags;
- (void)setDisplayTags:(NSMutableArray*)someTags;

- (IBAction)removeTag:(id)sender;

@end
