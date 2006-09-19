//
//  PreferenceController.h
//  punakea
//
//  Created by Johannes Hoffart on 29.08.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LoginItemsAE.h"

@interface PreferenceController : NSWindowController {
	NSUserDefaultsController *userDefaultsController;
	
	BOOL startOnLogin;
}

@end
