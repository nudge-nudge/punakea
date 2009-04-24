//
//  PATrialLicense.m
//  punakea
//
//  Created by Daniel on 24.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PATrialLicense.h"



int const	NUMBER_OF_DAYS_FOR_EVALUATION_PERIOD = 30;


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
	NSString *checksumString = [NSString stringWithFormat:@"%@ %@",
								(NSString *)[userDefaults objectForKey:@"License.StartDate"],
								(NSString *)[userDefaults objectForKey:@"License.MajorAppVersion"]];
	
	SSCrypto *crypto = [[[SSCrypto alloc] init] autorelease];
	[crypto setClearTextWithString:checksumString];
	
	NSString *digest = [[crypto digest:@"SHA-1"] hexval];
	
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

@end
