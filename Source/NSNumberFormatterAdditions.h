//
//  NSNumberFormatterAdditions.h
//  punakea
//
//  Created by Daniel on 16.05.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSNumberFormatter (NSNumberFormatterAdditions)

- (NSString *)stringFromFileSize:(unsigned long long)size;

@end
