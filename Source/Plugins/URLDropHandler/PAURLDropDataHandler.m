//
//  PAURLDropDataHandler.m
//  punakea
//
//  Created by Johannes Hoffart on 10.09.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "PAURLDropDataHandler.h"



@interface PAURLDropDataHandler (PrivateAPI)

- (NSData*)dragDataWithEntries:(NSArray*)entries;

@end

@implementation PAURLDropDataHandler

/**
data is NSDictionary with keys:
 "" : URL
 "title" : title
*/
- (NNTaggableObject*)fileDropData:(id)data
{
	NSString *url = [data objectForKey:@"url"];
	NSString *tempName = [[data objectForKey:@"title"] stringByAppendingString:@".webloc"];
	
	// replace non-file characters
	NSMutableString *copy = [[tempName mutableCopy] autorelease];
	[copy replaceOccurrencesOfString:@":" withString:@"_" options:0 range:NSMakeRange(0,[tempName length])];
	[copy replaceOccurrencesOfString:@"/" withString:@"_" options:0 range:NSMakeRange(0,[tempName length])];
	
	NSString *filename = copy;	
	NSString *filePath = [self destinationForNewFile:filename];
	
	NSMutableDictionary *weblocPlist = [NSMutableDictionary dictionaryWithCapacity:1];
	[weblocPlist setObject:url forKey:@"URL"];
	
	[weblocPlist writeToFile:filePath atomically:YES];
	
	// Hide WEBLOC extension
	NSDictionary *fileAttributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
															   forKey:NSFileExtensionHidden];
	
	[[NSFileManager defaultManager] setAttributes:fileAttributes
									 ofItemAtPath:filePath
											error:NULL];
	
	return [NNFile fileWithPath:filePath];
}

- (NSDragOperation)performedDragOperation
{
		return NSDragOperationCopy;
}

@end
