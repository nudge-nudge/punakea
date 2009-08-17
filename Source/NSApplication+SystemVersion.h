//
//  NSApplication+SystemVersion.h
//  punakea
//
//  Created by dl on 17.08.09.
//  Copyright 2009 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSApplication (SystemVersion)

- (void)getSystemVersionMajor:(unsigned *)major
                        minor:(unsigned *)minor
                       bugFix:(unsigned *)bugFix;

@end
