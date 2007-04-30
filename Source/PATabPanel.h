//
//  PATabPanel.h
//  punakea
//
//  Created by Daniel on 30.04.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PATabPanel : NSTabView {

	IBOutlet NSSplitView		*resizableSplitView;
	
	NSRect						gripRect;
	BOOL						gripDragged;
	NSSize						gripDragOffset;
	
}

@end
