//
//  PAStatusBarProgressIndicator.h
//  punakea
//
//  Created by Daniel on 22.05.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PAStatusBarButtonCell.h"


@interface PAStatusBarProgressIndicator : NSControl {

	NSString					*identifier;
	
	NSProgressIndicator			*progressIndicator;
	
	NSString					*stringValue;
	
	NSTextAlignment				alignment;
	
}

+ (PAStatusBarProgressIndicator *)statusBarProgressIndicator;	/**< Use this for init */

- (NSString *)identifier;
- (void)setIdentifier:(NSString *)anIdentifier;
- (NSControlSize)controlSize;
- (void)setControlSize:(NSControlSize)size;
- (NSProgressIndicatorStyle)style;
- (void)setStyle:(NSProgressIndicatorStyle)style;
- (NSString *)stringValue;
- (void)setStringValue:(NSString *)aString;

@end
