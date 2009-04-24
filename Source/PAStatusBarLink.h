//
//  PAStatusBarLink.h
//  punakea
//
//  Created by Daniel on 21.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class PAStatusBar;

@interface PAStatusBarLink : NSControl {

	PAStatusBar					*statusBar;
	
	NSString					*identifier;
	
	NSString					*stringValue;
	
	NSTextAlignment				alignment;
	
}

+ (PAStatusBarLink *)statusBarLink;

- (PAStatusBar *)statusBar;
- (void)setStatusBar:(PAStatusBar *)sb;
- (NSString *)identifier;
- (void)setIdentifier:(NSString *)anIdentifier;
- (NSString *)stringValue;
- (void)setStringValue:(NSString *)aString;

@end
