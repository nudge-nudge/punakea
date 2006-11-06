//
//  PAFileCache.m
//  punakea
//
//  Created by Johannes Hoffart on 06.11.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "PAFileCache.h"

int const PAFILECACHE_CYCLETIME = 2.0;

NSString * const TAGGER_OPEN_COMMENT = @"###begin_tags###";
NSString * const TAGGER_CLOSE_COMMENT = @"###end_tags###";

@interface PAFileCache (PrivateAPI)

- (void)syncCache;

- (NSArray*)keywordsForComment:(NSString*)comment;
- (NSArray*)commentForKeywords:(NSArray*)keywords;

- (NSString*)finderSpotlightCommentForFile:(PAFile*)file;

@end

@implementation PAFileCache

#pragma mark init
- (id)initWithTags:(PATags*)allTags;
{
	if (self = [super init])
	{
		cache = [[NSMutableDictionary alloc] init];
		cacheLock = [[NSLock alloc] init];
		
		// create cache cleanup timer
		timer = [NSTimer scheduledTimerWithTimeInterval:PAFILECACHE_CYCLETIME
												 target:self
											   selector:@selector(startSyncCacheThread:)
											   userInfo:nil
												repeats:YES];
		
		tags = allTags;
	}
	return self;
}

#pragma mark external
- (NSArray*)keywordsForFile:(PAFile*)file
{
	[cacheLock lock];
	
	NSArray *keywords = [cache objectForKey:file];
	
	[cacheLock unlock];
	
	if (!keywords)
	{		
		// the file wasn't cached
		// read comment from file and return converted keywords
		NSString *comment = [self finderSpotlightCommentForFile:file];
		keywords = [self keywordsForComment:comment];
	}
	
	return keywords;
}

- (void)writeKeywords:(NSArray*)keywords toFile:(PAFile*)file
{
	[cacheLock lock];
	
	[cache setObject:keywords forKey:file];
	
	[cacheLock unlock];
}

#pragma mark internal
- (void)startSyncCacheThread:(NSTimer*)timer
{
	[ThreadWorker workOn:self
			withSelector:@selector(syncCache)
			  withObject:nil
		  didEndSelector:nil];
}

- (void)syncCache
{
	// look at every file
	// compare comment to cache
	// if equal, remove cache
	
	[cacheLock lock];
		
	NSEnumerator *e = [cache keyEnumerator];
	PAFile *file;
	
	while (file = [e nextObject])
	{
		NSString *comment = [[NSFileManager defaultManager] commentForURL:[NSURL fileURLWithPath:[file path]]];
		NSArray *keywords = [self keywordsForComment:comment];
		
		NSArray *cachedKeywords = [cache objectForKey:file];
		
		// check if cache can be discarded
		if ([[NSSet setWithArray:keywords] isEqualToSet:[NSSet setWithArray:cachedKeywords]])
		{
			[cache removeObjectForKey:file];
		}
		else
		{
			[self writeFileCache:file];
		}
	}
	
	[cacheLock unlock];
}

- (void)writeFileCache:(PAFile*)file
{
	NSArray *keywords = [cache objectForKey:file];
	
	// create comment
	NSString *keywordComment = [self commentForKeywords:keywords];
	NSString *finderComment = [self finderCommentIgnoringKeywordsForFile:file];
	
	[[NSFileManager defaultManager] setComment:[finderComment stringByAppendingString:keywordComment]
										forURL:[NSURL fileURLWithPath:[file path]]];
}

#pragma mark helper
- (NSArray*)keywordsForComment:(NSString*)comment
{
	NSRange openCommentRange = [comment rangeOfString:TAGGER_OPEN_COMMENT];
	NSRange closeCommentRange = [comment rangeOfString:TAGGER_CLOSE_COMMENT];
	
	if (openCommentRange.location != NSNotFound)
	{
		NSString *keywordString = [comment substringWithRange:NSMakeRange(openCommentRange.location + openCommentRange.length,
																						 closeCommentRange.location - openCommentRange.location - openCommentRange.length)];
	
		NSArray *components = [keywordString componentsSeparatedByString:@";"];
		
		// check if there are any keywords
		if ([components count] == 1 && [[components objectAtIndex:0] isEqualToString:@""])
		{
			return [NSArray array];
		}
		else
		{
			NSArray *keywords = [NSMutableArray array];
			NSEnumerator *e = [components objectEnumerator];
			NSString *component;
			
			while (component = [e nextObject])
			{
				// validate keywordstring-component
				@try 
				{
					[self validateKeyword:component];
					[keywords addObject:[component substringFromIndex:1]];
				} 
				@catch (NSException *e) 
				{
						// ignore keyword - TODO inform user
						NSLog(@"%@ ignored",component);
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
	
- (NSArray*)commentForKeywords:(NSArray*)keywords
{
	NSMutableString *comment = [NSMutableString stringWithString:TAGGER_OPEN_COMMENT];
	
	NSEnumerator *e = [keywords objectEnumerator];
	NSString *keyword;
	
	if (keyword = [e nextObject])
	{
		[comment appendFormat:@"@%@",keyword];
	}
	
	while (keyword = [e nextObject])
	{
		[comment appendFormat:@";@%@",keyword];
	}
	
	[comment appendString:TAGGER_CLOSE_COMMENT];
	
	return comment;
}

- (NSString*)finderCommentIgnoringKeywordsForFile:(PAFile*)file
{
	NSString *currentFinderSpotlightComment = [self finderSpotlightCommentForFile:file];
	
	// delete old tag comment
	NSRange openCommentRange = [currentFinderSpotlightComment rangeOfString:TAGGER_OPEN_COMMENT];
	NSRange closeCommentRange = [currentFinderSpotlightComment rangeOfString:TAGGER_CLOSE_COMMENT];
	
	NSString *finderSpotlightCommentWithoutTags;
	
	if (openCommentRange.location != NSNotFound)
	{
		NSString *commentBeforeTags = [currentFinderSpotlightComment substringWithRange:NSMakeRange(0,openCommentRange.location)];
		int lengthOfCommentAfterTags = [currentFinderSpotlightComment length] - closeCommentRange.location - closeCommentRange.length;
		NSString *commentAfterTags = [currentFinderSpotlightComment substringWithRange:NSMakeRange(closeCommentRange.location + closeCommentRange.length,
																								   lengthOfCommentAfterTags)];
		finderSpotlightCommentWithoutTags = [commentBeforeTags stringByAppendingString:commentAfterTags];
	}
	else
	{
		finderSpotlightCommentWithoutTags = currentFinderSpotlightComment;
	}
	
	return finderSpotlightCommentWithoutTags;
}

#pragma mark helper helpers
- (NSString*)finderSpotlightCommentForFile:(PAFile*)file
{
	MDItemRef mdItem = NULL;
    CFStringRef path = (CFStringRef)[file path];
    NSString *comment = nil;
    
    if (path && (mdItem = MDItemCreate(CFGetAllocator(path), path))) {
        comment = (NSString *)MDItemCopyAttribute(mdItem, kMDItemFinderComment);
        CFRelease(mdItem);
        [comment autorelease];
    }
	
	if (!comment)
		return @"";
	else
		return comment;
}

- (void)validateKeyword:(NSString*)keyword
{
	if (!keyword ||
		![keyword hasPrefix:@"@"] ||
		[keyword length] == 0 ||
		![tags tagForName:[keyword substringFromIndex:1]])
	{
		NSException *e = [NSException exceptionWithName:@"InvalidKeywordException"
												 reason:@"user fiddled with comment"
											   userInfo:nil];
		@throw e;
	}
}

@end
