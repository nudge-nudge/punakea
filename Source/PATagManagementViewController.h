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


@interface PATagManagementViewController : PAViewController {
	PATagger *tagger;
	PATags *tags;
}

- (id)initWithNibName:(NSString*)nibName;

@end
