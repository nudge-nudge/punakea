//
//  PATag.h
//  punakea
//
//  Created by Johannes Hoffart on 15.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PATag : NSObject {
	NSString *name;
	NSString *query;
}

-(id)initWithName:(NSString*)aName;
-(id)initWithName:(NSString*)aName query:(NSString*)aQuery;

-(NSString*)name;
-(NSString*)query;
-(void)setName:(NSString*)aName;
-(void)setQuery:(NSString*)aQuery;

@end
