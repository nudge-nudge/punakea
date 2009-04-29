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
		//timeLimitedBetaExpirationDate = [[NSDate alloc] initWithString:@"2009-06-30 23:59:59 +0200"];	// CEST = +0200!
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
		if ([trialLicense isValidForThisAppVersion])
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
	[licenseKeyWindow makeFirstResponder:licenseKeyWindowProgressIndicator];
	
	[licenseKeyWindowProgressIndicator setHidden:NO];
	[licenseKeyWindowProgressIndicator startAnimation:self];
	
	[self showThankYouSheet];
	
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
	if (![self license]) return;
	
	if([[self license] type] == PALicenseTypeTrial)
	{
		PATrialLicense *l = (PATrialLicense *)[self license];
		
		[userDefaults setObject:@"Trial" forKey:@"License.Type"];
		[userDefaults setObject:[l startDate] forKey:@"License.StartDate"];
		[userDefaults setObject:[NSNumber numberWithInt:[l majorAppVersion]] forKey:@"License.MajorAppVersion"];
		[userDefaults setObject:[l checksum] forKey:@"License.Checksum"];
	}
	else
	{
		PARegisteredLicense *l = (PARegisteredLicense *)[self license];
		
		[userDefaults setObject:@"Registered" forKey:@"License.Type"];
		[userDefaults setObject:[l name] forKey:@"License.Name"];
		[userDefaults setObject:[l key] forKey:@"License.Key"];
		[userDefaults setObject:[NSNumber numberWithInt:[l majorAppVersion]] forKey:@"License.MajorAppVersion"];
		[userDefaults setObject:[l checksum] forKey:@"License.Checksum"];
	}
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
	if ([self hasTrialLicense])
	{
		PATrialLicense *l = (PATrialLicense *)[self license];
		return [l hasExpired];
	}
	else if ([self isTimeLimitedBeta])
	{
		NSDate *now = [NSDate date];
		NSDate *laterDate = [timeLimitedBetaExpirationDate laterDate:now];
		return [now isEqualToDate:laterDate];
	}
	else
	{
		return NO;
	}
}

- (void)relaunch
{
	// Code from
	// http://vgable.com/blog/2008/10/05/restarting-your-cocoa-application/
	
	NSString *killArg1AndOpenArg2Script = @"kill -9 $1 \n open \"$2\"";
	
	// NSTask needs its arguments to be strings
	NSString *ourPID = [NSString stringWithFormat:@"%d",
						[[NSProcessInfo processInfo] processIdentifier]];
	
	// This will be the path to the app bundle,
	// not the executable inside it; exactly what "open" wants
	NSString * pathToUs = [[NSBundle mainBundle] bundlePath];
	
	NSArray *shArgs = [NSArray arrayWithObjects:@"-c",						// -c tells sh to execute the next argument, passing it the remaining arguments.
												killArg1AndOpenArg2Script,
												@"",						//$0 path to script (ignored)
												ourPID,						//$1 in restartScript
												pathToUs,					//$2 in the restartScript
												nil];

	NSTask *restartTask = [NSTask launchedTaskWithLaunchPath:@"/bin/sh" arguments:shArgs];
	
	[restartTask waitUntilExit];
}


#pragma mark Modal Windows
- (IBAction)showEnterLicenseKeyWindow:(id)sender
{
	// Reset window
	[licenseKeyWindowProgressIndicator setHidden:YES];
	[licenseKeyWindowNameTextField setStringValue:@""];
	[licenseKeyWindowKeyTextField setStringValue:@""];
	
	[NSApp runModalForWindow:licenseKeyWindow];
}

- (void)showThankYouSheet
{
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert setMessageText:NSLocalizedStringFromTable(@"THANK_YOU",@"Registration",@"")];
	[alert setInformativeText:NSLocalizedStringFromTable(@"THANK_YOU_INFORMATIVE",@"Registration",@"")];
	[alert addButtonWithTitle:NSLocalizedStringFromTable(@"THANK_YOU_QUIT_AND_RELAUNCH_BUTTON",@"Registration",@"")];
	
	[alert setAlertStyle:NSInformationalAlertStyle];
	
	[alert beginSheetModalForWindow:licenseKeyWindow
					  modalDelegate:self 
					 didEndSelector:@selector(relaunch)
						contextInfo:nil];
}

- (IBAction)showVersionHasExpiredWindow:(id)sender
{
	NSWindow *w;
	if ([self isTimeLimitedBeta])
		w = timeLimitedExpirationWindow;
	else
		w = trialExpirationWindow;
		
	[NSApp runModalForWindow:w];
}

- (IBAction)terminate:(id)sender
{
	[NSApp terminate:self];
}


#pragma mark Window Delegate
- (void)windowWillClose:(NSNotification *)notification
{
	[NSApp stopModal];
}

- (IBAction)purchase:(id)sender
{
	NSURL *url = [NSURL URLWithString:NSLocalizedStringFromTable(@"STORE", @"Urls", nil)];
	[[NSWorkspace sharedWorkspace] openURL:url];
	[NSApp terminate:self];
}

- (IBAction)upgrade:(id)sender
{
	NSURL *url = [NSURL URLWithString:NSLocalizedStringFromTable(@"UPGRADE", @"Urls", nil)];
	[[NSWorkspace sharedWorkspace] openURL:url];
	[NSApp terminate:self];
}


#pragma mark Accessors
- (PALicense *)license
{
	return license;
}

- (void)setLicense:(PALicense *)aLicense
{
	[license release];
	license = [aLicense retain];
}

- (NSDate *)timeLimitedBetaExpirationDate
{
	return timeLimitedBetaExpirationDate;
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
