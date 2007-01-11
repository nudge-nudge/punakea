//
//  PAFile.m
//  punakea
//
//  Created by Johannes Hoffart on 15.09.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "PAFile.h"

NSString * const TAGGER_OPEN_COMMENT = @"###begin_tags###";
NSString * const TAGGER_CLOSE_COMMENT = @"###end_tags###";

@interface PAFile (PrivateAPI)

- (void)commonInit;

- (void)setPath:(NSString*)path;
- (NSString*)filename; /**< name AND extension (if there is any) */

- (BOOL)isEqualToFile:(PAFile*)otherFile;

- (NSArray*)tagsInSpotlightComment;
- (NSArray*)keywordsForComment:(NSString*)comment;
- (NSArray*)keywordsForComment:(NSString*)comment isValid:(BOOL*)isValid;
- (NSString*)finderTagComment;
- (NSString*)finderCommentIgnoringKeywords;
- (NSString*)finderSpotlightComment;

- (BOOL)caseRenameToPath:(NSString*)newPath;

/**
loads tags from backing storage
 @return tags read from storage
 */
- (NSMutableSet*)loadTagsFromStorage;

/**
loads tags from kMDItemFinderComment
 @return tags parsed from spotlight finder comment
 */
- (NSMutableSet*)loadTagsFromNSMetadataItem:(NSMetadataItem*)metadataItem;

/**
helper method
 
 returns the destination for a file to be written
 use this to get a destination for the dropped data, it
 will consider user settings of managing files
 @param fileName name of the new file
 @return complete path for the new file. save the drop data there
 */ 
- (NSString*)destinationForNewFile:(NSString*)fileName;

/**
helper method
 
 checks if the self is already located in the managed files directory (or a subdirectory).
 if this returns YES, the file should not be moved again.
 */
- (BOOL)isInManagedHierarchy;

- (NSString*)pathForFiles;

@end

@implementation PAFile

#pragma mark init+dealloc
// common initializer
- (void)commonInit
{	
	workspace = [NSWorkspace sharedWorkspace];
	fileManager = [NSFileManager defaultManager];
}

- (id)initWithPath:(NSString*)aPath
{
	if (self = [super init])
	{		
		[self setPath:aPath];
		tags = [[self loadTags] retain];
		
		[self commonInit];
		
		[self readMetadata];
	}
	return self;
}

- (id)initWithFileURL:(NSURL*)url
{
	NSParameterAssert([url isFileURL]);
	
	return [self initWithPath:[url path]];
}

- (id)initWithNSMetadataItem:(NSMetadataItem*)metadataItem;
{
	if (self = [super init])
	{
		tags = [[self loadTagsFromNSMetadataItem:metadataItem] retain];
		
		[self setPath:[metadataItem valueForAttribute:(id)kMDItemPath]];
		
		[self commonInit];
		
		id value;		
		[self setDisplayName:[metadataItem valueForAttribute:(id)kMDItemDisplayName]];
		[self setContentTypeIdentifier:[metadataItem valueForAttribute:(id)kMDItemContentType]];
		[self setContentTypeTree:[metadataItem valueForAttribute:@"kMDItemContentTypeTree"]];
		
		value = [PATaggableObject replaceMetadataValue:[metadataItem valueForAttribute:(id)kMDItemLastUsedDate]
										  forAttribute:(id)kMDItemLastUsedDate];
		if(value) [self setLastUsedDate:value];
		
		value = [PATaggableObject replaceMetadataValue:[metadataItem valueForAttribute:@"kMDItemContentTypeTree"]
										  forAttribute:@"kMDItemContentTypeTree"];
		if([value isEqualTo:@"DOCUMENTS"])
		{
			// Bookmarks that are stored as webloc file don't have the right content type,
			// so we set it here
			NSString *path = [metadataItem valueForAttribute:(id)kMDItemPath];
			if(path && [path hasSuffix:@"webloc"])
			{
				// Set new value for Content Type Tree
				value = @"BOOKMARKS";
				
				/*
				 // Set new value for Display Name
				 NSString *displayName = [item valueForAttribute:(id)kMDItemDisplayName];
				 [item setValue:[displayName substringToIndex:[displayName length]-7] forAttribute:(id)kMDItemDisplayName];
				 */
			}
		}
		[self setContentType:value];
	}
	return self;
}	

- (void)dealloc
{
	CFRelease(mdItem);
	[path release];
	[super dealloc];
}

+ (PAFile*)fileWithPath:(NSString*)aPath
{
	PAFile *file = [[PAFile alloc] initWithPath:aPath];
	return [file autorelease];
}

+ (NSArray*)filesWithFilepaths:(NSArray*)filepaths
{
	NSMutableArray *files = [NSMutableArray array];
	
	NSEnumerator *e = [filepaths objectEnumerator];
	NSString *path;
	
	while (path = [e nextObject])
	{
		[files addObject:[self fileWithPath:path]];
	}
	
	return files;
}
	
+ (PAFile*)fileWithFileURL:(NSURL*)url
{
	PAFile *file = [[PAFile alloc] initWithFileURL:url];
	return [file autorelease];
}

+ (PAFile*)fileWithNSMetadataItem:(NSMetadataItem*)metadataItem
{
	PAFile *file = [[PAFile alloc] initWithNSMetadataItem:metadataItem];
	return [file autorelease];
}

#pragma mark accessors
- (NSString *)path
{
	return path;
}

- (void)setPath:(NSString *)aPath
{
	[aPath retain];
	[path release];
	path = aPath;
}

- (NSString*)standardizedPath
{
	return [path stringByStandardizingPath];
}

// overwriting method of abstract class
// TODO waterjoe
- (NSString *)displayName
{
	return [path lastPathComponent];
}

- (NSString*)filename
{
	return [path lastPathComponent];
}

- (NSString*)extension
{
	return [path pathExtension];
}

- (NSString*)directory
{
	return [path stringByDeletingLastPathComponent];
}

- (BOOL)isDirectory
{
	BOOL isDirectory;
	[fileManager fileExistsAtPath:[self standardizedPath] isDirectory:&isDirectory];
	return isDirectory;
}

- (NSImage*)icon
{
	return [workspace iconForFile:path];
}

- (NSString *)description
{
	return [@"file:" stringByAppendingString:path];
}

/*- (NSString *)album
{
	return album;
}

- (void)setAlbum:(NSString *)anAlbum
{
	[album release];
	album = [anAlbum retain];
}

- (NSString *)authors
{
	return authors;
}

- (void)setAuthors:(NSString *)theAuthors
{
	[authors release];
	authors = [theAuthors retain];
}*/

#pragma mark euality testing
- (BOOL)isEqual:(id)other 
{
	if (!other || ![other isKindOfClass:[self class]]) 
        return NO;
    if (other == self)
        return YES;
	
    return [self isEqualToFile:other];
}

- (BOOL)isEqualToFile:(PAFile*)otherFile 
{
	if ([path isEqual:[otherFile path]])
		return YES;
	else
		return NO;
}

- (unsigned)hash 
{
	return [path hash];
}

#pragma mark comparison
- (NSComparisonResult)compare:(PAFile*)aFile
{
	return [[self name] compare:[aFile name]];
}

#pragma mark copying
- (id)copyWithZone:(NSZone *)zone
{
	PAFile *newFile = [[PAFile alloc] initWithPath:[[[self path] copy] autorelease]];
	
	// abstract class instance vars
	[newFile setTags:[[[self tags] copy] autorelease]];
	[newFile setRetryCount:[self retryCount]];
	
	return newFile;
}

#pragma mark abstract implemented
- (BOOL)saveTags
{	
	NSLog(@"saving %@ to %@",[self tags],[self filename]);
	
	// create comment
	NSString *keywordComment = [self finderTagComment];
	NSString *finderComment = [self finderCommentIgnoringKeywords];
	
	BOOL success = [fileManager setComment:[finderComment stringByAppendingString:keywordComment]
													   forURL:[NSURL fileURLWithPath:[self path]]];
	return success;
}

- (void)handleFileManagement
{
	if (![self isInManagedHierarchy])
	{
		NSString *newFullPath = [self destinationForNewFile:[self filename]];
		
		// TODO error handling
		[fileManager movePath:[self path] toPath:newFullPath handler:nil];
		
		// update path to reflect new location
		[self setPath:newFullPath];
		
		[nc postNotificationName:PATaggableObjectUpdate object:self userInfo:nil];
	}
}

- (BOOL)renameTo:(NSString*)newName errorWindow:(NSWindow*)window
{
	errorWindow = window;
	
	NSString *newPath = [[self directory] stringByAppendingPathComponent:newName];
	BOOL success;
	
	// handle capitalization change separate
	if([[self path] compare:newPath options:NSCaseInsensitiveSearch] == NSOrderedSame)
	{
		success = [self caseRenameToPath:newPath];
	}
	else
	{
		success = [fileManager movePath:[self path] toPath:newPath handler:self];
	}
	
	// update path to reflect new location
	if (success)
	{
		[self setPath:newPath];
	
		[nc postNotificationName:PATaggableObjectUpdate object:self userInfo:nil];
	}
	
	return success;
}

- (BOOL)caseRenameToPath:(NSString*)newPath
{
	BOOL success;
	
	NSString *tempDir = NSTemporaryDirectory();
	
	if (tempDir == nil)
		return NO;
	
	NSString *tempPath = [tempDir stringByAppendingPathComponent:[self filename]];
	success = [fileManager movePath:[self path] toPath:tempPath handler:self];
	
	if (success)
		success = [fileManager movePath:tempPath toPath:newPath handler:self];
	
	return success;
}

- (BOOL)validateNewName:(NSString*)newName
{
	NSString *newDestination = [[self directory] stringByAppendingPathComponent:newName];
	
	return (![fileManager fileExistsAtPath:newDestination] || 
			([newDestination compare:[self path] options:NSCaseInsensitiveSearch] == NSOrderedSame));
}

#pragma mark file error handling
-(BOOL)fileManager:(NSFileManager *)manager shouldProceedAfterError:(NSDictionary *)errorInfo
{
	NSString *informativeText;
	informativeText = [NSString stringWithFormat:
		NSLocalizedStringFromTable(@"ALREADY_EXISTS_INFORMATION", @"FileManager", @""),
		[errorInfo objectForKey:@"ToPath"]];
	
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	
	// TODO: Support correct error message text for more types of errors
	if([[errorInfo objectForKey:@"Error"] isEqualTo:@"Already Exists"])
	{
		[alert setMessageText:NSLocalizedStringFromTable([errorInfo objectForKey:@"Error"], @"FileManager", @"")];
		[alert setInformativeText:informativeText];
	} else {
		[alert setMessageText:NSLocalizedStringFromTable(@"Unknown Error", @"FileManager", @"")];
	}
	
	[alert addButtonWithTitle:@"OK"];
	[alert setAlertStyle:NSWarningAlertStyle];  
	
	[alert beginSheetModalForWindow:errorWindow
	                  modalDelegate:self
					 didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
					    contextInfo:nil];
	
	return NO;
}

#pragma mark spotlight comment integration
- (NSMutableSet*)loadTags
{
	NSArray *tags = [self tagsInSpotlightComment];
	return [NSMutableSet setWithArray:tags];
}

- (NSMutableSet*)loadTagsFromNSMetadataItem:(NSMetadataItem*)metadataItem;
{
	NSString *finderComment = [metadataItem valueForAttribute:(id)kMDItemFinderComment];
	NSArray *keywords = [self keywordsForComment:finderComment];
	NSArray *tagsInComment = [globalTags tagsForNames:keywords];
	return [NSMutableSet setWithArray:tagsInComment];
}

- (NSArray*)tagsInSpotlightComment
{
	NSArray *keywords = [self keywordsForComment:[self finderSpotlightComment]];
	NSArray *tagsInComment = [globalTags tagsForNames:keywords];
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
						[globalTags validateKeyword:component];
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

- (NSString*)finderTagComment
{
	if ([[self tags] count] == 0)
		return @"";
	
	NSMutableString *comment = [NSMutableString stringWithString:TAGGER_OPEN_COMMENT];
	
	NSEnumerator *e = [[self tags] objectEnumerator];
	NSString *keyword;
	
	while (keyword = [[e nextObject] name])
	{
		[comment appendFormat:@"@%@;",keyword];
	}
	
	[comment appendString:TAGGER_CLOSE_COMMENT];
	
	return comment;
}

- (NSString*)finderCommentIgnoringKeywords
{
	NSString *currentFinderSpotlightComment = [self finderSpotlightComment];
	
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

- (NSString*)finderSpotlightComment
{
	MDItemRef mdItem = NULL;
    CFStringRef filePath = (CFStringRef)[self path];
    NSString *comment = nil;
    
    if (filePath && (mdItem = MDItemCreate(CFGetAllocator(filePath), filePath))) {
        comment = (NSString *)MDItemCopyAttribute(mdItem, kMDItemFinderComment);
        CFRelease(mdItem);
    }
	
	if (!comment)
		return @"";
	else
		return [comment autorelease];
}

#pragma mark file management helper
- (NSString*)destinationForNewFile:(NSString*)fileName
{
	// check if main directory folder contains file
	// increment until directory is found/created where file can be place
	NSString *managedRoot = [self pathForFiles];
	NSString *destination;
	int i = 1;
	
	while (true)
	{
		NSString *directory = [managedRoot stringByAppendingFormat:@"/%i/",i];
		
		if ([fileManager fileExistsAtPath:directory] == NO) 
			[fileManager createDirectoryAtPath:directory attributes:nil];
		
		destination = [directory stringByAppendingPathComponent:fileName];
		
		// if file doesn't exists in directory, use this one
		if (![fileManager fileExistsAtPath:destination])
			break;
		
		i++;
	}
	
	return destination;
}

- (NSString*)pathForFiles
{ 
	NSString *directory = [[NSUserDefaults standardUserDefaults] objectForKey:@"General.ManagedFilesLocation"];
	directory = [directory stringByExpandingTildeInPath]; 
	
	if ([fileManager fileExistsAtPath:directory] == NO) 
		[fileManager createDirectoryAtPath:directory attributes: nil];
	
	return directory; 
}

- (BOOL)isInManagedHierarchy
{
	NSString *managedRoot = [self pathForFiles];
	return [[self path] hasPrefix:managedRoot];
}


#pragma mark Misc
- (MDItemRef)readMetadata
{
	CFStringRef filePath = (CFStringRef)[self path];
	mdItem = MDItemCreate(CFGetAllocator(filePath), filePath);
	
	id value = (id)MDItemCopyAttribute(mdItem, kMDItemDisplayName);	
	[self setDisplayName:value];
	value = (id)MDItemCopyAttribute(mdItem, kMDItemContentType);	
	[self setContentTypeIdentifier:value];
	value = (id)MDItemCopyAttribute(mdItem, @"kMDItemContentTypeTree");	
	[self setContentTypeTree:value];
	
	value = [PATaggableObject replaceMetadataValue:(id)MDItemCopyAttribute(mdItem, kMDItemLastUsedDate)
									  forAttribute:(id)kMDItemLastUsedDate];
	if(value) [self setLastUsedDate:value];
	
	value = [PATaggableObject replaceMetadataValue:(id)MDItemCopyAttribute(mdItem, @"kMDItemContentTypeTree")
									  forAttribute:@"kMDItemContentTypeTree"];
	if([value isEqualTo:@"DOCUMENTS"])
	{
		// Bookmarks that are stored as webloc file don't have the right content type,
		// so we set it here
		NSString *path = [self path];
		if(path && [path hasSuffix:@"webloc"])
		{
			// Set new value for Content Type Tree
			value = @"BOOKMARKS";

			/*
			 // Set new value for Display Name
			 NSString *displayName = [item valueForAttribute:(id)kMDItemDisplayName];
			 [item setValue:[displayName substringToIndex:[displayName length]-7] forAttribute:(id)kMDItemDisplayName];
			 */
		}
	}
	[self setContentType:value];
	
	return mdItem;
}

// Compatibility mode for PAQuery
- (id)valueForAttribute:(id)attribute
{
	if([attribute isEqualTo:kMDItemContentType]) return [self contentTypeIdentifier];
	if([attribute isEqualTo:@"kMDItemContentTypeTree"]) return [self contentType];
	if([attribute isEqualTo:kMDItemDisplayName]) return [self displayName];
	if([attribute isEqualTo:kMDItemPath]) return [self path];
	if([attribute isEqualTo:kMDItemLastUsedDate]) return [self lastUsedDate];
	return nil;
}

@end
