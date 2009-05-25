//
//  NNActiveAppSavingPanel.h
//  punakea
//
//  Created by Johannes Hoffart on 25.05.09.
//  Copyright 2009 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
 A panel that can save the last active app that was active before it.
 This can be used for invoking e.g. the Tagger and the Sidebar.
 */
@interface NNActiveAppSavingPanel : NSPanel {
	BOOL								activatesLastActiveApp;
	
	ProcessSerialNumber					lastActiveProcess;	/**< Indicates the process that was front before showing the sidebar */
}

- (BOOL)activatesLastActiveApp;
- (void)setActivatesLastActiveApp:(BOOL)flag;

- (void)setLastActiveApp:(ProcessSerialNumber)serialNumber;
- (void)activateLastActiveApp;

@end
