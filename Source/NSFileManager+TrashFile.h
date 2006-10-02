//
//  NSFileManager+TrashFile.h
//  punakea
//
//  Created by Daniel on 02.10.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PAFile.h"


@interface NSFileManager (TrashFile)

- (BOOL)trashFileAtPath:(NSString *)path;

@end
