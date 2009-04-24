//
//  PARegistrationLicense.m
//  punakea
//
//  Created by Daniel on 23.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PALicense.h"



@interface PALicense (PrivateAPI)

- (BOOL)validateLicenseKey:(NSString *)key;

@end



@implementation PALicense

#pragma mark Init + Dealloc
- (id)init
{
	if (self = [super init])
	{
		userDefaults = [NSUserDefaults standardUserDefaults];
	}
	
	return self;
}

- (void)dealloc
{
	[checksum release];
	[super dealloc];
}



#pragma mark Action
- (BOOL)isValidForThisAppVersion
{
	NSLog(@"ERROR - isValidForThisAppVersion needs to be implemented by subclasses.");
}



#pragma mark Accessors
- (PALicenseType)type
{
	return type;
}

- (void)setType:(PALicenseType)theType
{
	type = theType;
}

- (int)majorAppVersion
{
	return majorAppVersion;
}

- (void)setMajorAppVersion:(int)version
{
	majorAppVersion = version;
}

- (NSString *)checksum
{
	return checksum;
}

- (void)setChecksum:(NSString *)aChecksum
{
	[checksum release];
	checksum = [aChecksum retain];
}

@end
