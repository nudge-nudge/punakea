//
//  PARegisteredLicense.h
//  punakea
//
//  Created by Daniel on 24.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PALicense.h"

//#import "EWSLib.h"
#import "validateLib.h"



@interface PARegisteredLicense : PALicense {
	
	NSString							*name;
	NSString							*key;
	
}

+ (PARegisteredLicense *)license;
+ (PARegisteredLicense *)licenseFromUserDefaults;

+ (BOOL)validateLicenseKey:(NSString *)aKey forName:(NSString *)aName;

- (NSString *)name;
- (void)setName:(NSString *)aName;
- (NSString *)key;
- (void)setKey:(NSString *)aKey;

@end
