//
//  NNTagToOpenMetaWriter.m
//  NNTagging
//
//  Created by Johannes Hoffart on 08.03.09.
//  Copyright 2009 nudge:nudge. All rights reserved.
//

#import "NNTagToOpenMetaWriter.h"

#import "NNFile.h"

#import "lcl.h"

@implementation NNTagToOpenMetaWriter

#pragma mark functionality
- (NSArray*)allTaggedObjects
{
	NNQuery *query = [[NNQuery alloc] init];
	NSArray *results = [query executeSynchronousQueryForString:@"kMDItemOMUserTags == '*'"];		
	[query release];
	return results;
}

- (BOOL)writeTags:(NSArray*)tags toFile:(NNFile*)file
{
	// extract unicode strings
	NSMutableArray* tagNames = [NSMutableArray array];
	
	for (NNTag* tag in tags)
	{
		[tagNames addObject:[tag name]];
	}
	
	NSError *error = [OpenMeta setUserTags:tagNames path:[file path]];
	
	if (error == nil)
	{
		return YES;
	}
	else
	{
		lcl_log(lcl_cnntagging,lcl_vError,@"Could not write tags to %@",[file path]);
		return NO;
	}
}

- (NSArray*)readTagsFromFile:(NNFile*)file 
			 creationOptions:(NNTagsCreationOptions)options
{
	NSError *error = nil;
	
	NSArray *tagNames = [OpenMeta getUserTags:[file path]
										error:&error];
	
	if (error == nil)
	{
		NSArray *tags = [[NNTags sharedTags] tagsForNames:tagNames
										  creationOptions:options];
		return tags;
	}
	else
	{
		NSDictionary *errorInfo = [error userInfo];
		
		if (errorInfo != nil)
		{
			NSString *errorString = [errorInfo objectForKey:@"info"];
			
			if (errorString != nil)
			{
				lcl_log(lcl_cnntagging,lcl_vError,@"Could not read tags from %@: %@",[file path], errorString);
			}
		}
		
		lcl_log(lcl_cnntagging,lcl_vError,@"Could not read tags from %@",[file path]);
		return nil;
	}
}

- (NSString*)queryStringForTag:(NNSimpleTag*)tag
{
	return [self queryStringForTag:tag negated:NO];
}

- (NSString*)queryStringForTag:(NNSimpleTag*)tag negated:(BOOL)negated
{
	// first, escape the ' and " in the tag name
	NSMutableString *mutableName = [[tag name] mutableCopy];
	[mutableName replaceOccurrencesOfString:@"\'" withString:@"\\\'" options:0 range:NSMakeRange(0, [mutableName length])];	
	[mutableName replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:0 range:NSMakeRange(0, [mutableName length])];	
	[mutableName replaceOccurrencesOfString:@"\\" withString:@"\\\\" options:0 range:NSMakeRange(0, [mutableName length])];	
	
	NSString *comparator = negated ? @"!=" : @"==";
	
	NSString *queryString = [NSString stringWithFormat:@"%@ %@ \"%@\"",[self spotlightMetadataField], comparator,mutableName];
	
	[mutableName release];
	
	return queryString;
}

- (NSString*)spotlightMetadataField
{
	return @"kMDItemOMUserTags";
}

- (NSString*)scopeLimiter
{
	return @"(kMDItemOMUserTags == \"*\") && ";
}

- (NSArray*)extractTagNamesFromSpotlightMetadataFieldValue:(id)tagsSpotlightMetadataFieldValue
{
	// value already is an array, simply return it
	// we need to call this method as other tagToFileWriter may need to parse the field
	return ((NSArray*) tagsSpotlightMetadataFieldValue);
}

@end
