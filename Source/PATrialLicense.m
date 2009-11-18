//
//  PATrialLicense.m
//  punakea
//
//  Created by Daniel on 24.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PATrialLicense.h"



NSInteger const	NUMBER_OF_DAYS_FOR_EVALUATION_PERIOD = 30;


@interface PATrialLicense (PrivateAPI)

- (NSString *)checksumWithStartDate:(NSDate *)aDate andMajorAppVersion:(NSInteger)version;

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
		[license setMajorAppVersion:[(NSNumber *)[userDefaults objectForKey:@"License.MajorAppVersion"] integerValue]];
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
- (BOOL)hasExpired
{
	return [self daysLeftForEvaluation] <= 0;
}

- (NSInteger)daysLeftForEvaluation
{
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;

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

- (NSString *)checksumWithStartDate:(NSDate *)aDate andMajorAppVersion:(NSInteger)version
{
	NSString *checksumString = [NSString stringWithFormat:@"%@ %ld",
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
