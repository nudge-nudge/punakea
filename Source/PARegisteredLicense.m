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

+ (OSStatus)installEngine;

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
		[license setMajorAppVersion:(NSString *)[userDefaults objectForKey:@"License.MajorAppVersion"]];
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
- (BOOL)hasValidChecksum
{
	NSString *checksumString = [NSString stringWithFormat:@"%@ %@ %@",
					(NSString *)[userDefaults objectForKey:@"License.Name"],
					(NSString *)[userDefaults objectForKey:@"License.Key"],
					(NSString *)[userDefaults objectForKey:@"License.MajorAppVersion"]];
	
	SSCrypto *crypto = [[[SSCrypto alloc] init] autorelease];
	[crypto setClearTextWithString:checksumString];
	
	NSString *digest = [[crypto digest:@"SHA1"] hexval];
	
	return [[self checksum] isEqualTo:digest];
}

+ (BOOL)validateLicenseKey:(NSString *)aKey forName:(NSString *)aName
{	
	eSellerate_DaysSince2000 timestamp; 

	// TODO: Strip off any whitespace
	
	timestamp = eWeb_ValidateSerialNumber([aKey UTF8String],
												[aName UTF8String],
												nil, 
												PUBLISHER_KEY); 
	if (timestamp) { 
		/* TO DO: handle validation success */ 
		NSLog(@"valid");
		return YES;
	} else { 
		/* TO DO: handle validation failure */ 
		NSLog(@"invalid");
		return NO;
	} 
}

- (BOOL)isValidForThisAppVersion
{
	return YES;
}

- (void)updateChecksum
{
	NSString *checksumString = [NSString stringWithFormat:@"%@ %@ %@",
								[self name],
								[self key],
								[self majorAppVersion]];
	
	SSCrypto *crypto = [[[SSCrypto alloc] init] autorelease];
	[crypto setClearTextWithString:checksumString];
	
	NSString *digest = [[crypto digest:@"SHA-1"] hexval];
	
	[self setChecksum:digest];
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
