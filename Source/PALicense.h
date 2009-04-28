//
//  PARegistrationLicense.h
//  punakea
//
//  Created by Daniel on 23.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SSCrypto/SSCrypto.h"


typedef enum _PALicenseType {
	PALicenseTypeTrial = 0,
	PALicenseTypeRegistered = 1,
} PALicenseType;


@interface PALicense : NSObject {

	NSUserDefaults						*userDefaults;
	
	PALicenseType						type;
	int									majorAppVersion;
	NSString							*checksum;
	
}

- (BOOL)isValidForThisAppVersion;

- (void)updateChecksum;

- (PALicenseType)type;
- (void)setType:(PALicenseType)theType;
- (int)majorAppVersion;
- (void)setMajorAppVersion:(int)version;
- (NSString *)checksum;
- (void)setChecksum:(NSString *)aChecksum;

@end
