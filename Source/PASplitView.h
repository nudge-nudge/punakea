//
//  PASplitView.h
//  punakea
//
//  Created by Daniel on 29.03.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PASplitView : NSSplitView
{

	NSRect					previousFrame1;
	NSRect					previousFrame2;
	
	NSString				*autosaveName;
	NSString				*defaults;
	
	float					minCoordinate1;
	float					maxCoordinate1;
	float					minCoordinate2;
	float					maxCoordinate2;
	
}

- (void)toggleSubviewAtIndex:(int)idx;

- (NSString *)autosaveName;
- (void)setAutosaveName:(NSString *)aName defaults:(NSString *)theDefaults;

@end
