//
//  TaggerInterface.m
//  punakea
//
//  Created by Johannes Hoffart on 05.02.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "PATagger.h"

NSString * const TAGGER_OPEN_COMMENT = @"###begin_tags###";
NSString * const TAGGER_CLOSE_COMMENT = @"###end_tags###";

@interface PATagger (PrivateAPI)

- (void)writeTags:(NSArray*)tags toFile:(PAFile*)file;
- (void)writeKeywords:(NSArray*)keywords toFile:(PAFile*)file;

@end

@implementation PATagger

//this is where the sharedInstance is held
static PATagger *sharedInstance = nil;

#pragma mark init
//constructor - only called by sharedInstance
- (id)sharedInstanceInit {
	self = [super init];
	if (self)
	{
		simpleTagFactory = [[PASimpleTagFactory alloc] init];
		tags = [[PATags alloc] init];
		
		fileCache = [[NSMutableDictionary alloc] init];
		
		// load the applescript for finder comments
		NSString* path = [[NSBundle mainBundle] pathForResource:@"findercomment" ofType:@"scpt"];
		if (path != nil)
		{
			NSURL* url = [NSURL fileURLWithPath:path];
			if (url != nil)
			{
				finderCommentScript = [[NSAppleScript alloc] initWithContentsOfURL:url error:nil];
			}
		}
	}
	return self;
}

#pragma mark tags and files
- (NSArray*)tagsOnFile:(PAFile*)file
{
	return [self tagsOnFiles:[NSArray arrayWithObject:file] includeTempTags:YES];
}

- (NSArray*)tagsOnFiles:(NSArray*)files
{
	return [self tagsOnFiles:files includeTempTags:YES];
}

- (NSArray*)tagsOnFiles:(NSArray*)files includeTempTags:(BOOL)includeTempTags
{
	NSMutableArray *keywords = [NSMutableArray array];
	
	NSEnumerator *fileEnumerator = [files objectEnumerator];
	PAFile *file;
	
	while (file = [fileEnumerator nextObject])
	{
		[keywords addObjectsFromArray:[self keywordsForFile:file]];
	}
	
	NSArray *resultTags = [self tagsForNames:keywords includeTempTags:includeTempTags];
	
	return resultTags;	
}

- (PATag*)tagForName:(NSString*)tagName
{
	return [self tagForName:tagName includeTempTag:YES];
}

- (PATag*)tagForName:(NSString*)tagName includeTempTag:(BOOL)includeTempTag
{
	PATag *tag = [tags tagForName:tagName];
	
	if (!tag && includeTempTag)
	{
		tag = [[PATempTag alloc] init];
	}
	
	return tag;
}

- (NSArray*)tagsForNames:(NSArray*)tagNames includeTempTags:(BOOL)includeTempTags
{
	NSMutableArray *result = [NSMutableArray array];
	
	NSEnumerator *e = [tagNames objectEnumerator];
	NSString *tagName;
	
	while (tagName = [e nextObject])
	{
		PATag *tag = [tags tagForName:tagName];
		
		if (!tag && includeTempTags)
		{
			tag = [[PATempTag alloc] initWithName:tagName];
		}
		
		if (tag && ![result containsObject:tag])
		{
			[result addObject:tag];
		}
	}
	
	return result;
}

- (PATag*)createTagForName:(NSString*)tagName
{
	PATag *tag = [self tagForName:tagName includeTempTag:NO];
	
	if (!tag)
	{
		tag = [simpleTagFactory createTagWithName:tagName];
		[tags addTag:tag];
	}
	
	return tag;
}

- (NSArray*)createTagsForNames:(NSArray*)tagNames
{
	NSMutableArray *result = [NSMutableArray array];
	
	NSEnumerator *e = [tagNames objectEnumerator];
	NSString *tagName;
	
	while (tagName = [e nextObject])
	{
		PATag *tag = [self tagForName:tagName includeTempTag:NO];
		
		if (!tag)
		{
			tag = [simpleTagFactory createTagWithName:tagName];
			[tags addTag:tag];
		}
		
		if (![result containsObject:tag])
		{
			[result addObject:tag];
		}
	}
	
	return result;
}

- (void)addTags:(NSArray*)someTags toFiles:(NSArray*)files
{
	NSEnumerator *fileEnumerator = [files objectEnumerator];
	PAFile *file;
	
	while (file = [fileEnumerator nextObject])
   {
	   NSMutableArray *tagsOnFile = [[[self tagsOnFiles:[NSArray arrayWithObject:file] includeTempTags:YES] mutableCopy] autorelease];
	   NSEnumerator *e = [someTags objectEnumerator];
	   PATag *tag;

	   while (tag = [e nextObject])
	   {
		   if (![tagsOnFile containsObject:tag])
		   {
			   [tagsOnFile addObject:tag];
			   [tag incrementUseCount];
		   }
	   }

	   [self writeTags:tagsOnFile toFile:file];
   }
}

- (void)addKeywords:(NSArray*)keywords toFiles:(NSArray*)files createSimpleTags:(BOOL)createSimpleTags
{
	NSArray *tagArray;
	
	if (createSimpleTags)
	{
		tagArray = [self createTagsForNames:keywords];
	}
	else
	{
		tagArray = [self tagsForNames:keywords includeTempTags:NO];
	}
	
	[self addTags:tagArray toFiles:files];
}

- (NSArray*)keywordsForFile:(PAFile*)file {
	// TODO check invalid strings
	
	NSArray *keywords;
	// check cache if it has some keywords for file
	
	@synchronized(fileCache)
	{
		if (keywords = [fileCache objectForKey:file])
		{
			NSLog(@"cache_hit");
			return keywords;
		}
		else
		{	
			// get comment
			NSString *finderSpotlightComment = [self finderSpotlightCommentForFile:file];
			
			// extract keywords
			NSRange openCommentRange = [finderSpotlightComment rangeOfString:TAGGER_OPEN_COMMENT];
			NSRange closeCommentRange = [finderSpotlightComment rangeOfString:TAGGER_CLOSE_COMMENT];
			
			if (openCommentRange.location != NSNotFound)
			{
				NSString *keywordString = [finderSpotlightComment substringWithRange:NSMakeRange(openCommentRange.location + openCommentRange.length,
																								 closeCommentRange.location - openCommentRange.location - openCommentRange.length)];
				
				NSArray *components = [keywordString componentsSeparatedByString:@";"];
				
				// check if there are any keywords
				if ([components count] == 1 && [[components objectAtIndex:0] isEqualToString:@""])
				{
					return [NSArray array];
				}
				else
				{
					keywords = [NSMutableArray array];
					NSEnumerator *e = [components objectEnumerator];
					NSString *component;
					
					while (component = [e nextObject])
					{
						// ignore tag: prefix ... TODO!
						[keywords addObject:[component substringFromIndex:1]];
					}
					return keywords;
				}
			}
			else
			{
				return [NSArray array];
			}
		}
	}
}

#pragma mark working with tags (renaming and deleting)
- (void)removeTag:(PATag*)tag
{
	PAQuery *query = [[PAQuery alloc] init];
	NSArray *files = [query filesForTag:tag];	
	
	[self removeTag:tag fromFiles:files];
}

- (void)renameTag:(NSString*)tagName toTag:(NSString*)newTagName
{
	PAQuery *query = [[PAQuery alloc] init];
	NSArray *files = [query filesForTag:[self tagForName:tagName]];	
	
	[self renameTag:tagName toTag:newTagName onFiles:files];
}

- (void)removeTag:(PATag*)tag fromFiles:(NSArray*)files
{
	NSEnumerator *fileEnumerator = [files objectEnumerator];
	PAFile *file;
	
	while (file = [fileEnumerator nextObject])
	{
		// get all tags, remove the specified one, write back to file
		NSMutableArray *someTags = [[[self tagsOnFiles:[NSArray arrayWithObject:file]] mutableCopy] autorelease];
		[someTags removeObject:tag];
		
		// decrement use count here, that way the other classes
		// don't have to care
		[tag decrementUseCount];
		[self writeTags:someTags toFile:file];
	}
}

- (void)removeTags:(NSArray*)someTags fromFiles:(NSArray*)files
{
	NSEnumerator *e = [someTags objectEnumerator];
	PASimpleTag *tag;
	
	while (tag = [e nextObject])
	{
		[self removeTag:tag fromFiles:files];
	}
}

- (void)renameTag:(NSString*)tagName toTag:(NSString*)newTagName onFiles:(NSArray*)files
{
	if ([tagName isEqualToString:newTagName])
	{
		// no renaming needed
		return;
	}
	
	NSEnumerator *fileEnumerator = [files objectEnumerator];
	PAFile *file;
	
	while (file = [fileEnumerator nextObject])
	{
		// get all tags, rename the specified one (delete/add), write back to file
		NSMutableArray *keywords = [[self keywordsForFile:file] mutableCopy];
		[keywords removeObject:tagName];
		[keywords addObject:newTagName];
		[self writeKeywords:keywords toFile:file];
		[keywords release];
	}
}

- (void)removeAllTagsFromFile:(PAFile *)file
{
	[self writeTags:[NSArray array] toFile:file];
}

#pragma mark private
- (void)writeTags:(NSArray*)tags toFile:(PAFile*)file
{
	if (!tags || [tags count] == 0)
		return;
	
	// get current finder spotlight comment
	NSString *currentFinderSpotlightComment = [self finderSpotlightCommentForFile:file];
	
	// delete old tag comment
	NSRange openCommentRange = [currentFinderSpotlightComment rangeOfString:TAGGER_OPEN_COMMENT];
	NSRange closeCommentRange = [currentFinderSpotlightComment rangeOfString:TAGGER_CLOSE_COMMENT];
	
	NSString *finderSpotlightCommentWithoutTags;
	
	if (openCommentRange.location != NSNotFound)
	{
		NSString *commentBeforeTags = [currentFinderSpotlightComment substringWithRange:NSMakeRange(0,openCommentRange.location)];
		int lengthOfCommentAfterTags = [currentFinderSpotlightComment length] - closeCommentRange.location - closeCommentRange.length;
		NSString *commentAfterTags = [currentFinderSpotlightComment substringWithRange:NSMakeRange(closeCommentRange.location,
																								   lengthOfCommentAfterTags)];
		finderSpotlightCommentWithoutTags = [commentBeforeTags stringByAppendingString:commentAfterTags];
	}
	else
	{
		finderSpotlightCommentWithoutTags = currentFinderSpotlightComment;
	}
		
	// create new tag comment
	NSMutableString *newTagComment = [NSMutableString stringWithString:TAGGER_OPEN_COMMENT];
	NSMutableArray *keywords = [NSMutableArray array];
	NSEnumerator *e = [tags objectEnumerator];
	PATag *tag;
	
	if (tag = [e nextObject])
	{
		[newTagComment appendFormat:@"@%@",[tag name]];
		[keywords addObject:[tag name]];
	}
	
	while (tag = [e nextObject])
	{
		[newTagComment appendFormat:@";@%@",[tag name]];
		[keywords addObject:[tag name]];
	}
	
	[newTagComment appendString:TAGGER_CLOSE_COMMENT];
	
	NSString *newFinderSpotlightComment = [finderSpotlightCommentWithoutTags stringByAppendingString:newTagComment];
	
	// write comment to end of finder spotlight comment
	[self writeFinderSpotlightComment:newFinderSpotlightComment ofFile:file keywords:keywords];
}

- (NSString*)finderSpotlightCommentForFile:(PAFile*)file
{
	MDItemRef *item = MDItemCreate(NULL,[file path]);
	CFTypeRef *comment = MDItemCopyAttribute(item,@"kMDItemFinderComment");
	
	if (!comment)
		return @"";
	else
		return (NSString*)comment;
}

- (void)writeFinderSpotlightComment:(NSString*)comment ofFile:(PAFile*)file keywords:(NSArray*)keywords
{
	// locking and delay because of finder drop hang
	[self createFileCacheFor:file keywords:keywords];
	[self performSelector:@selector(writeStringToFinderSpotlightCommentOfFile:)
			   withObject:[NSArray arrayWithObjects:comment,file,nil]
			   afterDelay:0.1];
}

// perform selector afterDelay takes only 1 argument
- (void)writeStringToFinderSpotlightCommentOfFile:(NSArray*)arguments
{
	@synchronized(self)
	{
		NSString *comment = [arguments objectAtIndex:0];
		PAFile *file = [arguments objectAtIndex:1];
		
		//NSLog(@"%@ to %@",comment,file);

		// create the first parameter
		NSAppleEventDescriptor* firstParameter =
		[NSAppleEventDescriptor descriptorWithString:comment];
		
		// create the second parameter
		NSAppleEventDescriptor* secondParameter =
			[NSAppleEventDescriptor descriptorWithString:[file path]];				
		
		// create and populate the list of parameters
		NSAppleEventDescriptor* parameters = [NSAppleEventDescriptor listDescriptor];
		[parameters insertDescriptor:firstParameter atIndex:1];
		[parameters insertDescriptor:secondParameter atIndex:2];
		
		// create the AppleEvent target
		ProcessSerialNumber psn = {0, kCurrentProcess};
		NSAppleEventDescriptor* target =
			[NSAppleEventDescriptor
				descriptorWithDescriptorType:typeProcessSerialNumber
									   bytes:&psn
									  length:sizeof(ProcessSerialNumber)];
		
		// create an NSAppleEventDescriptor with the script's method name to call,
		// this is used for the script statement: "on show_message(user_message)"
		// Note that the routine name must be in lower case.
		NSAppleEventDescriptor* handler =
			[NSAppleEventDescriptor descriptorWithString:
				[@"write_comment" lowercaseString]];
		
		// create the event for an AppleScript subroutine,
		// set the method name and the list of parameters
		NSAppleEventDescriptor* event =
			[NSAppleEventDescriptor appleEventWithEventClass:kASAppleScriptSuite
													 eventID:kASSubroutineEvent
											targetDescriptor:target
													returnID:kAutoGenerateReturnID
											   transactionID:kAnyTransactionID];
		[event setParamDescriptor:handler forKeyword:keyASSubroutineName];
		[event setParamDescriptor:parameters forKeyword:keyDirectObject];
		
		NSDictionary *errors = [NSDictionary dictionary];
		
	//	NSLog(@"pre");
		
		// call the event in AppleScript
		NSAppleEventDescriptor *desc = [finderCommentScript executeAppleEvent:event error:&errors];

//		NSLog(@"past");
//		
//		NSLog(@"desc: %@",desc);
//		NSLog(@"errors: %@",errors);
		
		[self removeFileCacheFor:file];
	}
}

#pragma mark threading stuff
- (void)createFileCacheFor:(PAFile*)file keywords:(NSArray*)keywords
{
	@synchronized(fileCache)
	{
		[fileCache setObject:[keywords retain] forKey:file];	
	}
}

- (void)removeFileCacheFor:(PAFile*)file
{
	@synchronized(fileCache)
	{
		NSArray *keywords = [fileCache objectForKey:file];
		[fileCache removeObjectForKey:file];
		[keywords release];
	}
}

#pragma mark accessors
- (PATags*)tags
{
	return tags;
}

- (void)setTags:(PATags*)allTags
{
	[allTags retain];
	[tags release];
	tags = allTags;
}

#pragma mark singleton stuff
- (void)dealloc {
	[super dealloc];
}

+ (PATagger*)sharedInstance {
	@synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[self alloc] sharedInstanceInit];
        }
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
        }
    }
    return sharedInstance;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

@end