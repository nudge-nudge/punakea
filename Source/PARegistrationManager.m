//
//  PARegistrationManager.m
//  punakea
//
//  Created by Daniel on 21.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PARegistrationManager.h"



@interface PARegistrationManager (PrivateAPI)

- (void)checkRegistrationInformation;

- (void)writeLicenseToDefaults;

@end



@implementation PARegistrationManager

static PARegistrationManager *sharedInstance = nil;

#pragma mark Init + Dealloc

- (id)sharedInstanceInit {
	if (self = [self initWithWindowNibName:@"Registration"])
	{		
		// Initialize self
		userDefaults = [NSUserDefaults standardUserDefaults];
		
		// EITHER - OR - Uncomment the respective line
		//timeLimitedBetaExpirationDate = [[NSDate alloc] initWithString:@"2008-06-30 23:59:59 +0200"];	// CEST = +0200!
		[self checkRegistrationInformation];
	}
	return self;
}

- (id)initWithWindowNibName:(NSString *)windowNibName
{
	if (self = [super initWithWindowNibName:windowNibName])
	{
		// Reference the window once to enforce loading of the Nib
		[self window];
	}
	return self;
}

- (void)awakeFromNib
{
	// nothing yet
}

- (void)dealloc
{
	[license release];
	[super dealloc];
}


#pragma mark Actions

/**
 Checks for a license in user defaults
 */
- (void)checkRegistrationInformation
{	
	// First, check if there's a valid registered license
	PARegisteredLicense *registeredLicense = [PARegisteredLicense licenseFromUserDefaults];
	if (registeredLicense)	// There was a valid registered license found
	{
		if ([registeredLicense isValidForThisAppVersion])
		{
			[self setLicense:registeredLicense];
		}
		else
		{
			// TODO: Handle case that license is out-of-date
		}
	}
		
	// Next, check for a trial license
	PATrialLicense *trialLicense = [PATrialLicense licenseFromUserDefaults];
	if (trialLicense)	// There was a valid trial license found
	{		
		if ([license isValidForThisAppVersion])
		{
			[self setLicense:trialLicense];
		}
		else
		{
			// TODO: Handle case that license is out-of-date
		}
	}
	
	// No registration information could be found in user defaults?
	if (![self license])
	{
		// Create a new trial license
		
		NSString *bundleVersionString = [[[NSBundle bundleForClass:[self class]] infoDictionary] 
										  objectForKey:@"CFBundleVersion"];
		
		int majorAppVersion = [[bundleVersionString substringToIndex:1] intValue];
		
		PATrialLicense *l = [PATrialLicense license];
		[l setStartDate:[NSDate date]];
		[l setMajorAppVersion:majorAppVersion];
		[l updateChecksum];
		
		[self setLicense:l];
		[self writeLicenseToDefaults];
	}
}

- (IBAction)confirmNewLicenseKey:(id)sender
{
	// TODO: Update GUI
	[licenseKeyWindowProgressIndicator startAnimation:self];
	
	BOOL validKey = [self validateLicenseKey:[licenseKeyWindowKeyTextField stringValue]];
	
	if (validKey)
	{
		[self saveLicenseKey:[licenseKeyWindowKeyTextField stringValue]
					withName:[licenseKeyWindowNameTextField stringValue]];
		
		NSLog(@"valid");
				
		[licenseKeyWindow performClose:self];
	}
	
	// TODO: Update GUI
	[licenseKeyWindowProgressIndicator stopAnimation:self];
}

- (void)writeLicenseToDefaults
{
	
}

- (BOOL)hasRegisteredLicense
{
	return [[self license] isKindOfClass:[PARegisteredLicense class]]; 
}
	
- (BOOL)hasTrialLicense
{
	return [[self license] isKindOfClass:[PATrialLicense class]]; 
}

- (BOOL)isTimeLimitedBeta
{
	return timeLimitedBetaExpirationDate != nil;
}

- (BOOL)hasExpired
{
	NSDate *now = [NSDate date];
	
	if ([self hasTrialLicense])
	{
		PATrialLicense *l = (PATrialLicense *)[self license];
		
		NSDate *dateOfExpiration = [[l startDate] addTimeInterval:NUMBER_OF_DAYS_FOR_EVALUATION_PERIOD * 60 * 60 * 24];
		NSDate *laterDate = [dateOfExpiration laterDate:now];
		
		return [now isEqualToDate:laterDate];
	}
	else if ([self isTimeLimitedBeta])
	{
		NSDate *laterDate = [timeLimitedBetaExpirationDate laterDate:now];
		
		return [now isEqualToDate:laterDate];
	}
	else {
		return NO;
	}
}


#pragma mark Modal Windows
- (IBAction)showEnterLicenseKeyWindow:(id)sender
{
	[licenseKeyWindow center];
	[licenseKeyWindow makeKeyAndOrderFront:self];
}

- (IBAction)showVersionHasExpiredWindow:(id)sender
{
	[[NSApplication sharedApplication] runModalForWindow:expirationWindow];
}

- (IBAction)stopModal:(id)sender
{
	[[NSApplication sharedApplication] stopModal];
}

- (IBAction)terminate:(id)sender
{
	[[NSApplication sharedApplication] terminate:self];
}


#pragma mark Accessors
- (NSString *)licenseName
{
	
}

- (NSString *)licenseKey
{
	
}

- (PALicense *)license
{
	return license;
}

- (void)setLicense:(PALicense *)aLicense
{
	[license release];
	license = [aLicense retain];
}


#pragma mark Singleton

+ (PARegistrationManager *)defaultManager {
	@synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[self alloc] sharedInstanceInit];
        }
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
        }
    }
    return sharedInstance;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (unsigned)retainCount
{
    return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

@end
