//
//  NSDateFormatter+FriendlyFormat.h
//  punakea
//
//  Created by Daniel on 10/23/06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSDateFormatter (FriendlyFormat)

- (NSString *)friendlyStringFromDate:(NSDate *)date;

@end
