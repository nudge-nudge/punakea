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
	
	CGFloat					minCoordinate1;
	CGFloat					maxCoordinate1;
	CGFloat					minCoordinate2;
	CGFloat					maxCoordinate2;
	
}

- (void)toggleSubviewAtIndex:(NSInteger)idx;

- (NSString *)autosaveName;
- (void)setAutosaveName:(NSString *)aName defaults:(NSString *)theDefaults;

@end
