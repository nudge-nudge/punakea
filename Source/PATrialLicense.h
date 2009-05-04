//
//  PATrialLicense.h
//  punakea
//
//  Created by Daniel on 24.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PALicense.h"


extern int const NUMBER_OF_DAYS_FOR_EVALUATION_PERIOD;


@interface PATrialLicense : PALicense {

	NSDate								*startDate;
	
}

+ (PATrialLicense *)license;
+ (PATrialLicense *)licenseFromUserDefaults;

- (BOOL)hasExpired;
- (int)daysLeftForEvaluation;

- (NSDate *)startDate;
- (void)setStartDate:(NSDate *)aDate;

@end
