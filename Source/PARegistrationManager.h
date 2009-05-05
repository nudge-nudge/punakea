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
	
	IBOutlet NSWindow					*licenseKeyWindow;
	IBOutlet NSWindow					*trialExpirationWindow;
	IBOutlet NSWindow					*timeLimitedExpirationWindow;
	
	IBOutlet NSTextField				*licenseKeyWindowErrorTextField;
	IBOutlet NSTextField				*licenseKeyWindowNameTextField;
	IBOutlet NSTextField				*licenseKeyWindowKeyTextField;
	
}

+ (PARegistrationManager *)defaultManager;

- (IBAction)confirmNewLicenseKey:(id)sender;
- (void)writeLicenseToDefaults;

- (IBAction)showEnterLicenseKeyWindow:(id)sender;
- (IBAction)showVersionHasExpiredWindow:(id)sender;
- (IBAction)terminate:(id)sender;
- (IBAction)purchase:(id)sender;
- (IBAction)upgrade:(id)sender;

- (BOOL)hasRegisteredLicense;
- (BOOL)hasTrialLicense;
- (BOOL)isTimeLimitedBeta;

- (BOOL)hasExpired;

- (PALicense *)license;
- (void)setLicense:(PALicense *)aLicense;
- (NSDate *)timeLimitedBetaExpirationDate;

@end
