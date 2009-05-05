//
//  PARegisteredLicense.m
//  punakea
//
//  Created by Daniel on 24.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PARegisteredLicense.h"



#define		PUBLISHER_ID			   "PUB5903417296"
#define		PUBLISHER_KEY			   "2XJJ-88RP-29SJ-5EQD-MV50"


@interface PARegisteredLicense (PrivateAPI)

- (NSString *)checksumWithKey:(NSString *)aKey forName:(NSString *)aName andMajorAppVersion:(int)version;

@end



@implementation PARegisteredLicense

#pragma mark Init + dealloc
+ (PARegisteredLicense *)license
{	
	return [[[PARegisteredLicense alloc] init] autorelease];
}

+ (PARegisteredLicense *)licenseFromUserDefaults
{
	PARegisteredLicense *license = [PARegisteredLicense license];
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	if ([[userDefaults objectForKey:@"License.Type"] isEqualTo:@"Registered"])
	{
		[license setName:(NSString *)[userDefaults objectForKey:@"License.Name"]];
		[license setKey:(NSString *)[userDefaults objectForKey:@"License.Key"]];
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
		[self setType:PALicenseTypeRegistered];
	}
	
	return self;
}

- (void)dealloc
{	
	[super dealloc];
}


#pragma mark Actions
+ (BOOL)validateLicenseKey:(NSString *)aKey forName:(NSString *)aName
{	
	eSellerate_DaysSince2000 timestamp; 
	
	timestamp = eWeb_ValidateSerialNumber([aKey UTF8String],
										  [aName UTF8String],
										  nil, 
										  PUBLISHER_KEY); 
	if (timestamp) { 
		return YES;
	} else { 
		return NO;
	} 
}

- (void)updateChecksum
{
	NSString *aChecksum = [self checksumWithKey:[self key] 
										forName:[self name]
							 andMajorAppVersion:[self majorAppVersion]];
	
	[self setChecksum:aChecksum];
}

- (NSString *)checksumWithKey:(NSString *)aKey forName:(NSString *)aName andMajorAppVersion:(int)version
{
	NSString *checksumString = [NSString stringWithFormat:@"%@ %@ %i",
								aKey, aName, version];
	
	SSCrypto *crypto = [[[SSCrypto alloc] init] autorelease];
	[crypto setClearTextWithString:checksumString];
	
	NSString *digest = [[crypto digest:@"SHA1"] hexval];
	
	return digest;
}


#pragma mark Accessors
- (NSString *)name
{
	return name;
}

- (void)setName:(NSString *)aName
{
	[name release];
	name = [aName retain];
}

- (NSString *)key
{
	return key;
}

- (void)setKey:(NSString *)aKey
{
	[key release];
	key = [aKey retain];
}

@end
