/*
	D E P R E C A T E D
*/

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
	
	NSMutableString *queryString = [NSMutableString stringWithString:@"kMDItemTextContent == '"];
	[queryString appendString:[textfieldDaniel stringValue]];
	[queryString appendString:@"'"];
	
	_query = [[NSMetadataQuery alloc] init];
	[_query setGroupingAttributes:[NSArray arrayWithObjects:(id)kMDItemKind, (id)kMDItemFSSize, nil]];
	
	// MDQueryRef query;
	/*_query = MDQueryCreate(kCFAllocatorDefault,
						  (CFStringRef*) queryString,
						  NULL,
						  NULL);
	MDQueryExecute(_query, kMDQuerySynchronous);*/
	NSPredicate *predicateToRun = nil;
	NSString *predicateFormat = @"kMDItemTextContent == %@";
	predicateToRun = [NSPredicate predicateWithFormat:predicateFormat, [textfieldDaniel stringValue]];
	
	[_query setPredicate:predicateToRun]; 
	
	[_query startQuery];
	
	/*CFIndex count = MDQueryGetResultCount(_query);
	for (i = 0; i < count; i++) {
		MDItemRef item = MDQueryGetResultAtIndex(_query, i);
		CFTypeRef typeref = MDItemCopyAttribute(item, CFSTR("kMDItemPath"));
		NSLog((CFStringRef) typeref);
	}*/
}
@end
