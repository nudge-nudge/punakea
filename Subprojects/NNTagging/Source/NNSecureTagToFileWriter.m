// Copyright (c) 2006-2013 nudge:nudge (Johannes Hoffart & Daniel Bär). All rights reserved.
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import "NNSecureTagToFileWriter.h"

NSString * const TAGGER_OPEN_COMMENT = @"###begin_tags###";
NSString * const TAGGER_CLOSE_COMMENT = @"###end_tags###";

@interface NNSecureTagToFileWriter (PrivateAPI)

- (NSArray*)tagsInSpotlightComment:(NSString*)comment creationOptions:(NNTagsCreationOptions)options;
- (NSArray*)keywordsForComment:(NSString*)comment isValid:(BOOL*)isValid;

@end

@implementation NNSecureTagToFileWriter

- (NSArray*)allTaggedObjects
{
	NNQuery *query = [[NNQuery alloc] init];
	NSArray *results = [query executeSynchronousQueryForString:@"kMDItemFinderComment == '*###begin_tags###*'"];		
	[query release];
	return results;
}

- (NSArray*)readTagsFromFile:(NNFile*)file
{
	return [self readTagsFromFile:file 
				  creationOptions:NNTagsCreationOptionFull 
						 useStore:NNFinderCommentSpotlightStore];
}

- (NSArray*)readTagsFromFile:(NNFile*)file 
			 creationOptions:(NNTagsCreationOptions)options
					useStore:(NNFinderCommentStore)store
{
	NSString *comment = [self commentForFile:file useStore:store];
	NSArray *loadedTags = [self tagsInComment:comment creationOptions:options];
	return loadedTags;
}

- (NSArray*)tagsInComment:(NSString*)comment
{
	return [self tagsInComment:comment
			   creationOptions:NNTagsCreationOptionNone];
}

- (NSArray*)tagsInComment:(NSString*)comment creationOptions:(NNTagsCreationOptions)options
{
	NSArray *keywords = [self keywordsForComment:comment];
	NSArray *tagsInComment = [[NNTags sharedTags] tagsForNames:keywords creationOptions:options];
	return tagsInComment;
}

- (NSArray*)keywordsForComment:(NSString*)comment
{
	BOOL notInterested;
	return [self keywordsForComment:comment isValid:&notInterested];
}

- (NSArray*)keywordsForComment:(NSString*)comment isValid:(BOOL*)isValid
{
	NSRange openCommentRange = [comment rangeOfString:TAGGER_OPEN_COMMENT];
	NSRange closeCommentRange = [comment rangeOfString:TAGGER_CLOSE_COMMENT];
	
	if (openCommentRange.location != NSNotFound)
	{
		NSRange tagRange = NSMakeRange(openCommentRange.location + openCommentRange.length,
									   closeCommentRange.location - openCommentRange.location - openCommentRange.length);
		
		NSRange seperatorRange = [comment rangeOfString:@";" options:0 range:tagRange];
		
		// if there are no ";", there are no tags
		if (seperatorRange.location == NSNotFound)
			return [NSArray array];
		
		NSString *keywordString = [comment substringWithRange:tagRange];
		
		NSArray *components = [keywordString componentsSeparatedByString:@";"];
		
		// check if there are any keywords
		if ([components count] == 1 && [[components objectAtIndex:0] isEqualToString:@""])
		{
			return [NSArray array];
		}
		else
		{
			NSMutableArray *keywords = [NSMutableArray array];
			NSEnumerator *e = [components objectEnumerator];
			NSString *component;
			
			while (component = [e nextObject])
			{
				// validate keywordstring-component
				@try 
				{
					if (component && [component isNotEqualTo:@""])
					{
						[[NNTags sharedTags] validateKeyword:component];
						[keywords addObject:[component substringFromIndex:1]];
					}
				} 
				@catch (NSException *exception) 
				{
					// if any invalid entries are detected
					// (such as non-existant tags)
					// force to write clean tags back to comment
					*isValid = NO;
				}
			}
			
			return keywords;
		}
	}
	else
	{
		return [NSArray array];
	}
}

- (NSString*)finderTagCommentForTags:(NSArray*)tags
{
	if ([tags count] == 0)
		return @"";
	
	NSMutableString *comment = [NSMutableString stringWithString:TAGGER_OPEN_COMMENT];
	
	for (NNTag *tag in tags)
	{
		NSString *keyword = [tag name];
		[comment appendFormat:@"%@%@;",[self prefix],keyword];
	}
	
	[comment appendString:TAGGER_CLOSE_COMMENT];
	
	return comment;
}

- (NSString*)finderCommentIgnoringKeywordsForFile:(NNFile*)file
{
	NSString *currentFinderSpotlightComment = [self commentForFile:file];
	
	// delete old tag comment
	NSRange openCommentRange = [currentFinderSpotlightComment rangeOfString:TAGGER_OPEN_COMMENT];
	NSRange closeCommentRange = [currentFinderSpotlightComment rangeOfString:TAGGER_CLOSE_COMMENT];
	
	NSString *finderSpotlightCommentWithoutTags;
	
	if (openCommentRange.location != NSNotFound)
	{
		NSString *commentBeforeTags = [currentFinderSpotlightComment substringWithRange:NSMakeRange(0,openCommentRange.location)];
		NSInteger lengthOfCommentAfterTags = [currentFinderSpotlightComment length] - closeCommentRange.location - closeCommentRange.length;
		NSString *commentAfterTags = [currentFinderSpotlightComment substringWithRange:NSMakeRange(closeCommentRange.location + closeCommentRange.length,
																								   lengthOfCommentAfterTags)];
		finderSpotlightCommentWithoutTags = [commentBeforeTags stringByAppendingString:commentAfterTags];
	}
	else
	{
		finderSpotlightCommentWithoutTags = currentFinderSpotlightComment;
	}
	
	// remove whitespace around comment
	NSString *trimmedComment = [finderSpotlightCommentWithoutTags stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	return trimmedComment;
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
	
	NSString *comparator = negated ? @"!=" : @"==";
	
	// form query with escaped tag name
	NSString *queryString = [NSString stringWithFormat:@"kMDItemFinderComment %@ \"*%@%@;*\"",comparator,[[NNTagStoreManager defaultManager] tagPrefix], mutableName];
	
	[mutableName release];
	
	return queryString;
}	

@end
