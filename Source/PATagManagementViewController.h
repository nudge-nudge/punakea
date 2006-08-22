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
	
	PATagger *tagger;
	PATags *tags;
	
	PAQuery *query;
}

- (id)initWithNibName:(NSString*)nibName;

- (IBAction)removeTag:(id)sender;

@end
