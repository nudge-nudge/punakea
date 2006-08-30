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

@interface PATagManagementViewController : PAViewController {
	IBOutlet NSTableView *tableView;
	IBOutlet NSArrayController *arrayController;
	
	PATagger *tagger;
	PATags *tags;
	PAQuery *query;
	
	BOOL deleting;
	BOOL renaming;
}

- (id)initWithNibName:(NSString*)nibName;

- (BOOL)isDeleting;
- (void)setDeleting:(BOOL)flag;
- (BOOL)isRenaming;
- (void)setRenaming:(BOOL)flag;

- (void)removeTagsFromFiles:(NSArray*)tags;
- (void)renameTag:(PATag*)oldTag toTag:(PATag*)newTag;

@end
