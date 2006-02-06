//
//  TaggerInterface.m
//  punakea
//
//  Created by Johannes Hoffart on 05.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "TaggerInterface.h"
#import "Matador.h"

@implementation TaggerInterface
-(void)writeSpotlightComment {
	NSLog(@"rennt weiter");
	[[Matador sharedInstance] setAttributeForFileAtPath:@"/Users/darklight/Desktop/punakea_test" name:@"kMDItemFinderComment" value:@"hoffarttest"];
}
@end
