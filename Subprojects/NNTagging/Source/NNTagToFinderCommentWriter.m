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

#import "NNTagToFinderCommentWriter.h"

#import "lcl.h"

NSString * const TAGGER_WHITESPACE_SEPARATOR = @"    ";

@interface NNTagToFinderCommentWriter (PrivateAPI)

/**
 Returns the Finder Comment using the Scripting Bridge
 (causes the finder to hang if the comment is read on drag'n'drop
 @param fileURL file to get comment for
 @return comment
 */
- (NSString *)commentForURL:(NSURL *)fileURL;

@end

@implementation NNTagToFinderCommentWriter

#pragma mark init
- (id)init
{
	if (self = [super init])
	{
		/* retrieve the Finder application Scripting Bridge object. */
		finder = [[SBApplication alloc] initWithBundleIdentifier:@"com.apple.finder"];
	}
	return self;
}

- (void)dealloc
{
	[finder release];
	[super dealloc];
}

#pragma mark accessors
- (NSString*)prefix
{
	return [[NNTagStoreManager defaultManager] tagPrefix];
}

- (void)setPrefix:(NSString*)aPrefix
{
	[[NNTagStoreManager defaultManager] setTagPrefix:aPrefix];
}

#pragma mark functionality
- (BOOL)writeTags:(NSArray*)tags toFile:(NNFile*)file
{
	// abstract method calls need to be implemented by subclass
	
	// read finder comment ignoring the old tags
	NSString *finderComment = [self finderCommentIgnoringKeywordsForFile:file];
	
	// generate string sequence for tags
	NSString *keywordComment = [self finderTagCommentForTags:tags];
	
	// compose complete finder comment string
	NSString *finderCommentWithWhitespaceSeparator = [finderComment stringByAppendingString:TAGGER_WHITESPACE_SEPARATOR];
	NSString *completeFinderComment = [finderCommentWithWhitespaceSeparator stringByAppendingString:keywordComment];
	
	BOOL success = [self setComment:completeFinderComment
							 forURL:[NSURL fileURLWithPath:[file path]]];
	return success;
}

/**
 * Pass call using NNFinderCommentSpotlightStore as default
 */
- (NSArray*)readTagsFromFile:(NNFile*)file 
			 creationOptions:(NNTagsCreationOptions)options;
{
	return [self readTagsFromFile:file
				  creationOptions:options
						 useStore:NNFinderCommentSpotlightStore];
}

- (NSArray*)readTagsFromFile:(NNFile*)file 
			 creationOptions:(NNTagsCreationOptions)options
					useStore:(NNFinderCommentStore)store
{
	NSLog(@"abstract method called: FAILURE");
	return nil;
}

- (NSArray*)tagsInComment:(NSString*)comment
{
	NSLog(@"abstract method called: FAILURE");
	return nil;
}

- (NSArray*)tagsInComment:(NSString*)comment creationOptions:(NNTagsCreationOptions)options
{
	NSLog(@"abstract method called: FAILURE");
	return nil;
}

- (NSArray*)keywordsForComment:(NSString*)comment
{
	NSLog(@"abstract method called: FAILURE");
	return nil;
}

- (NSString*)finderTagCommentForTags:(NSArray*)tags
{
	NSLog(@"abstract method called: FAILURE");
	return nil;
}

- (NSString*)finderCommentIgnoringKeywordsForFile:(NNFile*)file
{
	NSLog(@"abstract method called: FAILURE");
	return nil;
}

- (NSString*)commentForFile:(NNFile*)file
{
	// by default the comment is read from the spotlight db.
	// high usage of this method might result in spotlight instability,
	// use with caution
	return [self commentForFile:file useStore:NNFinderCommentSpotlightStore];
}

- (NSString*)commentForFile:(NNFile*)file useStore:(NNFinderCommentStore)store
{
	NSString *comment = nil;
	
	if (store == NNFinderCommentSpotlightStore)
	{
		// comment is read from mditems. this is needed because
		// using the finder scripting bridge to get the comment causes
		// deadlock with the Finder on drag'n'drop tagging
		MDItemRef mdItem = NULL;
		CFStringRef filePath = (CFStringRef)[file path];
		
		if (filePath && (mdItem = MDItemCreate(CFGetAllocator(filePath), filePath))) {
			comment = (NSString *)MDItemCopyAttribute(mdItem, kMDItemFinderComment);
			CFRelease(mdItem);
		}
		
		if (!comment)
			comment = @"";
		else
			[comment autorelease];
	}
	else if (store == NNFinderCommentFinderStore)
	{
		
		// comment is read from the finder using the scripting bridge.
		// this is faster and more stable than using the spotlight db,
		// but causes hangs on finder dragging
		NSURL *fileURL = [NSURL fileURLWithPath:[file path]];
		comment = [self commentForURL:fileURL];
	}
	
	return comment;
}

#pragma mark finder comment
// Sets the Finder comment (Spotlight comment) field via the Finder
- (BOOL)setComment:(NSString *)comment forURL:(NSURL *)fileURL;
{
    NSParameterAssert(comment != nil);
	NSParameterAssert([fileURL isFileURL]);
    NSString *path = [fileURL path];
	
	// do nothing if there is no file
	if (![[NSFileManager defaultManager] fileExistsAtPath:path])
	{
		return NO;
	}
	
	// a maximum of 1012 characters can be written
	if (([comment length] + [[path lastPathComponent] length]) > 1012)
	{
		lcl_log(lcl_cnntagging,lcl_vError,@"Finder comment length exceeds maximum character count - cannot write to comment");
		return NO;
	}
	
	BOOL result;
	
	@try {
		/* retrieve a reference to our finder item asking for it by location */
		FinderItem * theItem = [[finder items] objectAtLocation: fileURL];
		
		/* attempt to set the comment for the Finder item.  */
		theItem.comment = comment;
		
		/* successful result */
		result = YES;
	}
	@catch(NSException *e) {
		result = NO;
	}
	
	/* return YES on success */
	return result;
}

// Gets the Finder comment (Spotlight comment) field via the Finder Scripting Bridge
- (NSString *)commentForURL:(NSURL *)fileURL;
{
    NSParameterAssert([fileURL isFileURL]);
	
	// handle fnf case gracefully
	if (![[NSFileManager defaultManager] fileExistsAtPath:[fileURL path]])
		return @"";
    
	NSString* result;
	
	@try {
		/* retrieve a reference to our finder item asking for it by location */
		FinderItem * theItem = [[finder items] objectAtLocation: fileURL];
		
		/* set the result.  */
		result = theItem.comment;
	}
	@catch(NSException *e) {
		result = nil;
	}
	
	/* return the comment (or nil on error). */
	return result;
}

- (NSString*)spotlightMetadataField
{
	return (NSString*)kMDItemFinderComment;
}

- (NSArray*)extractTagNamesFromSpotlightMetadataFieldValue:(id)tagsSpotlightMetadataFieldValue
{
	// the field contains the finder comment as value, parse accordingly
	NSArray *tagNames = [self keywordsForComment:(NSString*)tagsSpotlightMetadataFieldValue];
	
	return tagNames;
}

@end
