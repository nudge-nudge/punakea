//
//  FileOutlineViewDelegateCategory.m
//  Punakea
//
//  Created by Daniel on 09.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "FileOutlineViewDelegateCategory.h"
#import "Controller.h"
#import <CoreServices/CoreServices.h>


@implementation Controller (FileOutlineViewDelegateCategory)
- (IBAction)danielTest:(id)sender {
	int i;
	
	NSMutableString *queryString = [NSMutableString stringWithString:@"kMDItemTextContent == '"];
	[queryString appendString:[textfieldDaniel stringValue]];
	[queryString appendString:@"'"];
	
	MDQueryRef query;
	query = MDQueryCreate(kCFAllocatorDefault,
						  (CFStringRef*) queryString,
						  NULL,
						  NULL);
	MDQueryExecute(query, kMDQuerySynchronous);
	
	CFIndex count = MDQueryGetResultCount(query);
	for (i = 0; i < count; i++) {
		MDItemRef item = MDQueryGetResultAtIndex(query, i);
		CFTypeRef typeref = MDItemCopyAttribute(item, CFSTR("kMDItemPath"));
		NSLog((CFStringRef) typeref);
	}
}
@end
