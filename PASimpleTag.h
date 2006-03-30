//
//  PATag.h
//  punakea
//
//  Created by Johannes Hoffart on 15.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PATag.h"


@interface PASimpleTag : PATag {
	NSString *name;
	NSString *query;
	NSCalendarDate *lastClicked;
	NSCalendarDate *lastUsed;
	unsigned long clickCount;
	unsigned long useCount;
	PATag* currentBestTag;
	
	//position in view
	NSRect rectInView;
}

- (id)initWithName:(NSString*)aName;

@end
