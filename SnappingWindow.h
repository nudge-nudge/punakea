//
//  SnappingWindow.h
//  SnappingWindow
//
//  Created by Matt Gemmell on Sun Jan 19 2003.
//  Use however you like.
//

#import <Cocoa/Cocoa.h>

@interface SnappingWindow : NSWindow {
    BOOL snapsToEdges;		/* whether or not the window snaps to edges */
    float snapTolerance;	/* distance from edge within which snapping occurs */
    BOOL snapping;		/* whether we're currently snapping to an edge */
    NSPoint dragStartLocation;	/* keeps track of last drag's mousedown point */
    float padding;    		/* how far from the edges we snap to */
}

/* Notification handlers */
- (void)windowMoved:(id)notification;

/* Helper methods */
- (void)springCoordinate:(float *)coord to:(float)coord inPoint:(NSPoint *)pt;

/* Accessor methods */
- (BOOL)snapsToEdges;
- (void)setSnapsToEdges:(BOOL)flag;

- (float)snapTolerance;
- (void)setSnapTolerance:(float)tolerance;

- (float)padding;
- (void)setPadding:(float)newPadding;

@end
