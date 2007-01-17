//
//  NSFileManager+PAExtensions.h
//  punakea
//
//  Created by Johannes Hoffart on 01.11.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
was taken from bibdesk (Adam Maxwell)
 */
@interface NSFileManager (PAExtensions)

- (BOOL)setComment:(NSString *)comment forURL:(NSURL *)fileURL;
- (NSString *)commentForURL:(NSURL *)fileURL;

@end
