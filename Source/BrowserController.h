//
//  BrowserController.h
//  punakea
//
//  Created by Johannes Hoffart on 04.07.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PATags.h"
#import "BrowserViewController.h"

@interface BrowserController : NSWindowController 
{
	PATags *tags;
}

- (id)initWithWindowNibName:(NSString*)windowNibName tags:allTags;

@end
