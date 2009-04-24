//
//  PATrialLicense.h
//  punakea
//
//  Created by Daniel on 24.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PALicense.h"


@interface PATrialLicense : PALicense {

	NSDate								*startDate;
	
}

- (BOOL)hasValidStartDate;

- (NSDate *)startDate;
- (void)setStartDate:(NSDate *)aDate;

@end
