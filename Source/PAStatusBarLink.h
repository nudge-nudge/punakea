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
	
	id							target;
	SEL							action;
	
	NSString					*identifier;
	NSString					*stringValue;	
	NSTextAlignment				alignment;
	
}

+ (PAStatusBarLink *)statusBarLink;

- (PAStatusBar *)statusBar;
- (void)setStatusBar:(PAStatusBar *)sb;

- (id)target;
- (void)setTarget:(id)aTarget;
- (SEL)action;
- (void)setAction:(SEL)selector;

- (NSString *)identifier;
- (void)setIdentifier:(NSString *)anIdentifier;
- (NSString *)stringValue;
- (void)setStringValue:(NSString *)aString;

@end
