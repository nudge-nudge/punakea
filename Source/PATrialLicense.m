//
//  PATrialLicense.m
//  punakea
//
//  Created by Daniel on 24.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PATrialLicense.h"



int const	NUMBER_OF_DAYS_FOR_EVALUATION_PERIOD = 30;


@interface PATrialLicense (PrivateAPI)

+ (PATrialLicense *)license;

- (NSString *)checksumWithStartDate:(NSDate *)aDate andMajorAppVersion:(int)version;

@end



@implementation PATrialLicense

#pragma mark Init + dealloc
+ (PATrialLicense *)license
{
	return [[[PATrialLicense alloc] init] autorelease];
}

+ (PATrialLicense *)licenseFromUserDefaults
{
	PATrialLicense *license = [PATrialLicense license];
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	if ([[userDefaults objectForKey:@"License.Type"] isEqualTo:@"Trial"])
	{
		[license setStartDate:(NSDate *)[userDefaults objectForKey:@"License.StartDate"]];
		[license setMajorAppVersion:[(NSNumber *)[userDefaults objectForKey:@"License.MajorAppVersion"] intValue]];
		[license setChecksum:(NSString *)[userDefaults objectForKey:@"License.Checksum"]];
	}
	
	if ([license hasValidChecksum])
		return license;
	else 
		return nil;
}

- (id)init
{
	if (self = [super init])
	{
		[self setType:PALicenseTypeTrial];
	}
	
	return self;
}

- (void)dealloc
{
	[startDate release];	
	[super dealloc];
}



#pragma mark Actions
- (BOOL)hasValidChecksum
{	
	NSString *oldChecksum = [self checksum];
	
	[self updateChecksum];
	
	return [[self checksum] isEqualTo:oldChecksum];
}

- (BOOL)isValidForThisAppVersion
{
	NSString *bundleVersionString = [[[NSBundle bundleForClass:[self class]] infoDictionary] 
									 objectForKey:@"CFBundleVersion"];
	
	int v = [[bundleVersionString substringToIndex:1] intValue];
	
	return [self hasValidChecksum] && ([self majorAppVersion] == v);
}

- (BOOL)hasExpired
{
	return [self daysLeftForEvaluation] <= 0;
}

- (int)daysLeftForEvaluation
{
	NSCalendar *cal = [NSCalendar currentCalendar];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;

	// Strip of any time information from the expiration date
	NSDate *expirationDate = [[self startDate] addTimeInterval:NUMBER_OF_DAYS_FOR_EVALUATION_PERIOD * 60 * 60 * 24];
	NSDateComponents *dateComponents = [cal components:unitFlags fromDate:expirationDate];
	expirationDate = [cal dateFromComponents:dateComponents];
	
	// Do the same for today's date
	dateComponents = [cal components:unitFlags fromDate:[NSDate date]];
	NSDate *now = [cal dateFromComponents:dateComponents];

	NSTimeInterval timeDiff = [now timeIntervalSinceDate:expirationDate] / (60 * 60 * 24 * -1);

	return timeDiff;
}

- (void)updateChecksum
{
	NSString *aChecksum = [self checksumWithStartDate:[self startDate]
								   andMajorAppVersion:[self majorAppVersion]];
	
	[self setChecksum:aChecksum];
}

- (NSString *)checksumWithStartDate:(NSDate *)aDate andMajorAppVersion:(int)version
{
	NSString *checksumString = [NSString stringWithFormat:@"%@ %i",
								aDate,
								version];
	
	SSCrypto *crypto = [[[SSCrypto alloc] init] autorelease];
	[crypto setClearTextWithString:checksumString];
	
	NSString *digest = [[crypto digest:@"SHA1"] hexval];
	
	return digest;
}


#pragma mark Accessors
- (NSDate *)startDate
{
	return startDate;
}

- (void)setStartDate:(NSDate *)aDate
{
	[startDate release];
	startDate = [aDate retain];
}

@end
