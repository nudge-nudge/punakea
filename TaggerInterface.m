//
//  TaggerInterface.m
//  punakea
//
//  Created by Johannes Hoffart on 05.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "TaggerInterface.h"
#import "Matador.h"

//for CFArray
#import <Carbon/Carbon.h>


@implementation TaggerInterface
-(void)writeSpotlightComment {
	NSLog(@"rennt weiter");
	NSMutableArray *tags = [NSMutableArray new];
	[tags addObject:@"testtag"];
	[tags addObject:@"ein schoener tag"];
	NSLog([tags objectAtIndex:0]);
	[[Matador sharedInstance] setAttributeForFileAtPath:@"/Users/darklight/Desktop/punakea_test" name:@"kMDItemKeywords" value:tags];
}
@end
