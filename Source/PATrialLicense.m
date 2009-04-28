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
		[license setMajorAppVersion:(int)[userDefaults objectForKey:@"License.MajorAppVersion"]];
		[license setChecksum:(NSString *)[userDefaults objectForKey:@"License.Checksum"]];
	}
	
	if ([license hasValidStartDate])
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
- (BOOL)hasValidStartDate
{
	// Check if there are any values in user defaults
	if (!([userDefaults objectForKey:@"License.StartDate"] &&
		  [userDefaults objectForKey:@"License.MajorAppVersion"]))
	{
		return NO;
	}
	
	NSString *checksumString = [self checksumWithStartDate:(NSDate *)[userDefaults objectForKey:@"License.StartDate"]
										andMajorAppVersion:(int)[userDefaults objectForKey:@"License.MajorAppVersion"]];
	
	SSCrypto *crypto = [[[SSCrypto alloc] init] autorelease];
	[crypto setClearTextWithString:checksumString];
	
	NSString *digest = [[crypto digest:@"SHA1"] hexval];
	
	return [[self checksum] isEqualTo:digest];
}

- (BOOL)isValidForThisAppVersion
{
}

- (BOOL)hasExpired
{
	NSDate *laterDate = [[NSDate date] laterDate:startDate];
	return ![laterDate isEqualToDate:startDate];
}

- (int)daysLeftForEvaluation
{
	return 7;
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
								[self startDate],
								[self majorAppVersion]];
	
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
