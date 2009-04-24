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

- (OSStatus)installEngine;

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
	
	if ([license hasValidKey])
		return license;
	else 
		return nil;
}

- (id)init
{
	if (self = [super init])
	{
		// Initialize the eSellerate system
		[self installEngine];
		
		[self setType:PALicenseTypeRegistered];
	}
	
	return self;
}

- (void)dealloc
{	
	[super dealloc];
}


#pragma mark Actions
- (BOOL)hasValidKey
{
	NSString *checksumString = [NSString stringWithFormat:@"%@ %@ %@",
					(NSString *)[userDefaults objectForKey:@"License.Name"],
					(NSString *)[userDefaults objectForKey:@"License.Key"],
					(NSString *)[userDefaults objectForKey:@"License.MajorAppVersion"]];
	
	SSCrypto *crypto = [[[SSCrypto alloc] init] autorelease];
	[crypto setClearTextWithString:checksumString];
	
	NSString *digest = [[crypto digest:@"SHA-1"] hexval];
	
	return [[self checksum] isEqualTo:digest];
}

- (BOOL)validateLicenseKey:(NSString *)key
{
	/*return eWeb_ValidateSerialNumber ([key UTF8String],		// Serial number
									  nil,					// No name based key in this example
									  nil,					// No extra data in this example
									  PUBLISHER_KEY);		// Publisher Key
	 */
	return YES;
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


#pragma mark eSellerate

/** 
 This function will ensure that the eSellerate engine is installed on the user's machine
 before attempting to do anything.
 
 @return OSStatus indicating the installation result
 */
- (OSStatus)installEngine
{	
	NSString *fwPath = [[NSBundle mainBundle] pathForResource:@"EWSMacCompress.tar.gz" ofType:nil];
	
	OSStatus error =  eWeb_InstallEngineFromPath([fwPath UTF8String]);
	
	if (error < E_SUCCESS) 
		NSRunAlertPanel(@"Punakea was unable to install the eSellerate engine.", @"", @"Ok", nil, nil);
	
	return error;
}

@end
