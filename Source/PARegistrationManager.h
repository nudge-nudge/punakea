//
//  PARegistrationManager.h
//  punakea
//
//  Created by Daniel on 21.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PALicense.h"
#import "PATrialLicense.h"
#import "PARegisteredLicense.h"



@interface PARegistrationManager : NSWindowController {

	NSUserDefaults						*userDefaults;
	
	PALicense							*license;
	NSDate								*timeLimitedBetaExpirationDate;
	
	// Window Outlets
	IBOutlet NSWindow					*licenseKeyWindow;
	IBOutlet NSWindow					*trialExpirationWindow;
	IBOutlet NSWindow					*timeLimitedExpirationWindow;
	
	// Outlets for License Key Window
	IBOutlet NSTabView					*tabView;
	IBOutlet NSTextField				*informativeTextField;
	IBOutlet NSButton					*unregisterButton;
	IBOutlet NSButton					*buyNowButton;
	IBOutlet NSTextField				*registeredToTextField;
	IBOutlet NSImageView				*warningImageView;
	IBOutlet NSTextField				*nameTextField;
	IBOutlet NSTextField				*keyTextField;
	
}

+ (PARegistrationManager *)defaultManager;

- (IBAction)confirmNewLicenseKey:(id)sender;
- (void)writeLicenseToDefaults;

- (IBAction)showLicenseManagerWindow:(id)sender;
- (IBAction)showVersionHasExpiredWindow:(id)sender;
- (IBAction)terminate:(id)sender;
- (IBAction)purchase:(id)sender;
- (IBAction)upgrade:(id)sender;
- (IBAction)unregister:(id)sender;
- (IBAction)switchToEnterTab:(id)sender;

- (BOOL)hasRegisteredLicense;
- (BOOL)hasTrialLicense;
- (BOOL)isTimeLimitedBeta;

- (BOOL)hasExpired;

- (PALicense *)license;
- (void)setLicense:(PALicense *)aLicense;
- (NSDate *)timeLimitedBetaExpirationDate;

@end
