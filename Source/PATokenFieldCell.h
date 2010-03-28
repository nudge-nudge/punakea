//
//  PATokenFieldCell.h
//  PATokenField
//
//  Created by Daniel on 27.03.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol PATokenFieldCellDelegate;


@interface PATokenFieldCell : NSTokenFieldCell {

}

@property (readwrite, assign) IBOutlet id<PATokenFieldCellDelegate> delegate;

@end


@protocol PATokenFieldCellDelegate <NSObject>

@optional
- (NSColor *)tokenFieldCell:(NSTokenFieldCell *)tokenFieldCell tokenForegroundColorForRepresentedObject:(id)representedObject;
- (NSColor *)tokenFieldCell:(NSTokenFieldCell *)tokenFieldCell tokenBackgroundColorForRepresentedObject:(id)representedObject;

// The NSTokenFieldCellDelegate protocol is available in 10.6 and later. Since we're currently building also for 
// 10.5, this is a copy of the protocol from AppKit. For future versions, delete this and let the protocol inherit
// from NSTokenFieldCellDelegate instead of NSObject.

// BEGIN - NSTokenFieldCellDelegate
- (NSArray *)tokenFieldCell:(NSTokenFieldCell *)tokenFieldCell completionsForSubstring:(NSString *)substring indexOfToken:(NSInteger)tokenIndex indexOfSelectedItem:(NSInteger *)selectedIndex;
- (NSArray *)tokenFieldCell:(NSTokenFieldCell *)tokenFieldCell shouldAddObjects:(NSArray *)tokens atIndex:(NSUInteger)index;
- (NSString *)tokenFieldCell:(NSTokenFieldCell *)tokenFieldCell displayStringForRepresentedObject:(id)representedObject;
- (NSString *)tokenFieldCell:(NSTokenFieldCell *)tokenFieldCell editingStringForRepresentedObject:(id)representedObject;
- (id)tokenFieldCell:(NSTokenFieldCell *)tokenFieldCell representedObjectForEditingString: (NSString *)editingString;
- (BOOL)tokenFieldCell:(NSTokenFieldCell *)tokenFieldCell writeRepresentedObjects:(NSArray *)objects toPasteboard:(NSPasteboard *)pboard;
- (NSArray *)tokenFieldCell:(NSTokenFieldCell *)tokenFieldCell readFromPasteboard:(NSPasteboard *)pboard;
- (NSMenu *)tokenFieldCell:(NSTokenFieldCell *)tokenFieldCell menuForRepresentedObject:(id)representedObject;
- (BOOL)tokenFieldCell:(NSTokenFieldCell *)tokenFieldCell hasMenuForRepresentedObject:(id)representedObject; 
- (NSTokenStyle)tokenFieldCell:(NSTokenFieldCell *)tokenFieldCell styleForRepresentedObject:(id)representedObject;
// END - NSTokenFieldDelegate

@end
