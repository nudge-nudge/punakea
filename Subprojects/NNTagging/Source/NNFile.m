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

#import "NNFile.h"

#import "lcl.h"

@interface NNFile (PrivateAPI)

- (void)commonInit;
- (NSDictionary*)readMetadataFromPath:(NSString*)filePath;
- (NSDictionary*)readMetadataFromMDItem:(MDItemRef)mdItem;

- (NSString*)filename; /**< name AND extension (if there is any) */
- (void)setKind:(NSString *)aString;

- (BOOL)isEqualToFile:(NNFile*)otherFile;

// spotlight comment integration
- (NSArray*)tagsInSpotlightComment;
- (NSArray*)keywordsForComment:(NSString*)comment;
- (NSArray*)keywordsForComment:(NSString*)comment isValid:(BOOL*)isValid;
- (NSString*)finderTagComment;
- (NSString*)finderCommentIgnoringKeywords;
- (NSString*)finderSpotlightComment;

// internal rename stuff
- (BOOL)caseRenameToPath:(NSString*)newPath;
- (void)continueRenaming:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)context;

/**
loads tags from backing storage
 @return tags read from storage
 */
- (NSMutableSet*)loadTags;

/**
helper method
 
 returns the destination for a file to be written
 use this to get a destination for the dropped data, it
 will consider user settings of managing files
 @param fileName name of the new file
 @return complete path for the new file. save the drop data there
 */ 
- (NSString*)destinationForNewFile:(NSString*)fileName;

- (NSString*)pathForFiles;

- (unsigned long long)sizeForFileAtPath:(NSString *)aPath;

@end


NSString * const NNFileSizeChangeOperation = @"NNFileSizeChangeOperation";


@implementation NNFile

#pragma mark init+dealloc
// common initializer
- (void)commonInit
{	
	workspace = [NSWorkspace sharedWorkspace];
	fileManager = [NSFileManager defaultManager];
	tagStoreManager = [NNTagStoreManager defaultManager];
	
//	sizeCached = 0;
}

- (id)initWithPath:(NSString*)aPath
{	
	if (self = [super init])
	{	
		[self commonInit];
		
		[self setPath:aPath];
        
        if ([fileManager fileExistsAtPath:aPath]) {
            NSDictionary* metadata = [self readMetadataFromPath:aPath];
            [self setDisplayName:[metadata objectForKey:(id)kMDItemDisplayName]];
            [self setKind:[metadata objectForKey:(id)kMDItemKind]];
            [self setContentType:[metadata objectForKey:(id)kMDItemContentType]];
            [self setLastUsedDate:[metadata objectForKey:(id)kMDItemLastUsedDate]];
            [self setContentTypeTree:[metadata objectForKey:(id)kMDItemContentTypeTree]];
		 
            [self setTags:[self loadTags]];
        } else {
            lcl_log(lcl_cnntagging, lcl_vError, @"Could not read metadata for %@, path does not exist", aPath);
        }
	}
	return self;
}

- (id)initWithPath:(NSString*)aPath
	   displayName:(NSString*)aDisplayName
			  kind:(NSString*)aKind
	   contentType:(NSString*)aContentType
		  lastUsed:(NSDate*)lastUsed
   contentTypeTree:(NSArray*)aContentTypeTree
			  tags:(NSArray*)someTags
{
	if (self = [super init])
	{
		[self commonInit];
		
		[self setPath:aPath];
		[self setDisplayName:aDisplayName];
		[self setKind:aKind];
		[self setContentType:aContentType];
		[self setLastUsedDate:lastUsed];
		[self setContentTypeTree:aContentTypeTree];
		[self setTags:[NSMutableSet setWithArray:someTags]];
	}
	return self;
}

- (void)dealloc
{
	[kind release];
	[path release];
	[super dealloc];
}

+ (NNFile*)fileWithPath:(NSString*)aPath
{
	NNFile *file = [[[NNFile alloc] initWithPath:aPath] autorelease];
	return file;
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
	
+ (NNFile*)fileWithPath:(NSString*)aPath
			displayName:(NSString*)aDisplayName
				   kind:(NSString*)aKind
			contentType:(NSString*)aContentType
			   lastUsed:(NSDate*)lastUsed
		contentTypeTree:(NSArray*)aContentTypeTree
				   tags:(NSArray*)someTags
{
	NNFile *file = [[NNFile alloc] initWithPath:aPath
									displayName:aDisplayName
										   kind:aKind
									contentType:aContentType
									   lastUsed:lastUsed
								contentTypeTree:aContentTypeTree
										   tags:someTags];
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

- (NSURL*)url
{
	return [NSURL fileURLWithPath:[self path]];
}

- (NSString*)standardizedPath
{
	return [path stringByStandardizingPath];
}

// overwriting method of abstract class
- (NSString*)filename
{
	return [path lastPathComponent];
}

- (NSString*)extension
{
	return [path pathExtension];
}

- (NSString*)parentDirectory
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

- (NSString *)kind
{
	return kind;
}

- (void)setKind:(NSString *)aString
{
	[kind release];
	kind = [aString retain];
}

- (NSString *)description
{
	return [@"file:" stringByAppendingString:path];
}


#pragma mark euality testing
- (BOOL)isEqual:(id)other 
{
	if (!other || ![other isKindOfClass:[self class]]) 
        return NO;
    if (other == self)
        return YES;
	
    return [self isEqualToFile:other];
}

- (BOOL)isEqualToFile:(NNFile*)otherFile 
{
	if (([path isEqual:[otherFile path]]) &&
		([[self tags] isEqual:[otherFile tags]]))
		return YES;
	else
		return NO;
}

- (NSUInteger)hash 
{
	return [path hash];
}

#pragma mark comparison
- (NSComparisonResult)compare:(NNFile*)aFile
{
	return [[self filename] compare:[aFile filename]];
}

#pragma mark copying
- (id)copyWithZone:(NSZone *)zone
{
	NNFile *newFile = [[NNFile alloc] initWithPath:[[[self path] copy] autorelease]];
	
	// abstract class instance vars
	[newFile setTags:[self tags]];
	[newFile setRetryCount:[self retryCount]];
	
	return newFile;
}

#pragma mark abstract implemented
- (BOOL)saveTags
{	
	// get the curent tagToFileWriter
	NNTagToFileWriter *tagToFileWriter = [tagStoreManager tagToFileWriter];
	
	// use tagToFileWriter to write tags to Finder's Spotlight Comment
	NSArray *tagArray = [tags allObjects];
	BOOL success = [tagToFileWriter writeTags:tagArray toFile:self];
	
	return success;
}

- (void)handleFileManagement
{
	// File management now takes place *every time* this method is called.
	// If the file is already in the managed folder, check if there's maybe
	// a better place to put it.
	
	NSLog(@"handling");
	
	BOOL success;
	NSError *error;
	
	NSString *newFullPath = [self destinationForNewFile:[self filename]];
	
	// Nothing to do. Path in managed folder is up to date.
	if (newFullPath == nil)
		return;
	
	success = [fileManager moveItemAtPath:[self path]
								   toPath:newFullPath
									error:&error];

	if (success)
	{
		// If file has been moved within the managed folder, clean up
		// (i.e. delete all empty folders)
		if (self.isInManagedHierarchy)
		{
			NSString *checkPath = [self.path stringByDeletingLastPathComponent];
			
			while (![[self.pathForFiles stringByStandardizingPath] isEqualToString:[checkPath stringByStandardizingPath]])
			{
				NSLog(checkPath);
				
				if ([[fileManager contentsOfDirectoryAtPath:checkPath error:NULL] count] == 0)
					[fileManager removeItemAtPath:checkPath error:NULL];
					 				
				checkPath = [checkPath stringByDeletingLastPathComponent];
			}
		}
	}
	else
	{
		if (!self.isInManagedHierarchy)
		{
			lcl_log(lcl_cnntagging,lcl_vError,@"Error while moving file to managed files folder: %@",[error localizedDescription]);
		} else {
			lcl_log(lcl_cnntagging,lcl_vError,@"Error while updating path to file within managed files folder: %@",[error localizedDescription]);
		}
	}
	
	// update path to reflect new location
	[self setPath:newFullPath];
}

- (BOOL)isWritable
{
	return [[NSFileManager defaultManager] isWritableFileAtPath:[self path]];
}

#pragma mark Renaming
- (void)renameTo:(NSString*)newName errorWindow:(NSWindow*)window
{
	errorWindow = window;
	
	// Return if there was no modification
	if([[self displayName] isEqualTo:newName])
		return;
	
	// newName might reflect only the displayName without suffix - "myfile.xml" or "myfile"
	NSDictionary *fileAttributes = [fileManager fileAttributesAtPath:[self path] traverseLink:NO];
	BOOL fileExtensionHidden = [[fileAttributes objectForKey:NSFileExtensionHidden] boolValue];
	
	// Let's assume that extensions may only match [a-zA-Z0-9]. So validate newExtension.	
	BOOL validNewExtension;
	NSString *newExtension = [newName pathExtension];	
	
	NSString *regexp = @"[a-zA-Z0-9]+";
	
	NSPredicate *regexpTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexp];
	
	if ([regexpTest evaluateWithObject:newExtension]) {
		// Match! newExtension may be a valid file extension.
		validNewExtension = YES;
	} else {
		// No match! This is not a valid file extension.
		validNewExtension = NO;
		newExtension = @"";
	}
	
	// ...and validated the old extension, too!
	BOOL validOldExtension;
	NSString *oldExtension = [self extension];
	
	if ([regexpTest evaluateWithObject:oldExtension]) {
		validOldExtension = YES;		
	} else {
		validOldExtension = NO;
		oldExtension = @"";
	}		
	
	// Go on!	
	if(!fileExtensionHidden && !validNewExtension)
	{
		// Keep extension, but change flag on file to hide it
		fileExtensionHidden = YES;
	}
	else if(fileExtensionHidden && validNewExtension)
	{
		// We want to show the extension
		fileExtensionHidden = NO;
	}
	
	// Context Info for passing to continueRenaming:returnCode:contextInfo
	// Will be released there
	NSMutableDictionary *contextInfo = [[NSMutableDictionary alloc] init];
	[contextInfo setObject:[NSNumber numberWithBool:fileExtensionHidden] forKey:@"fileExtensionHidden"];
	[contextInfo setObject:newExtension forKey:@"newExtension"];
	[contextInfo setObject:oldExtension forKey:@"oldExtension"];
	[contextInfo setObject:[NSNumber numberWithBool:validNewExtension] forKey:@"validNewExtension"];
	[contextInfo setObject:[NSNumber numberWithBool:validOldExtension] forKey:@"validOldExtension"];
	[contextInfo setObject:newName forKey:@"newName"];
	
	// Show modal sheet if extension has changed
	if(validOldExtension && validNewExtension && ![newExtension isCaseInsensitiveLike:oldExtension])
	{
		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		
		NSString *text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"CHANGE_FILE_EXTENSION", @"FileManager", @""), [self extension], newExtension];
		[alert setMessageText:text];
		
		text = NSLocalizedStringFromTable(@"CHANGE_FILE_EXTENSION_INFORMATIVE", @"FileManager", @"");
		[alert setInformativeText:text];
		
		text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"CHANGE_FILE_EXTENSION_KEEP_OLD", @"FileManager", @""), [self extension]];
		[alert addButtonWithTitle:text];
		text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"CHANGE_FILE_EXTENSION_USE_NEW", @"FileManager", @""), newExtension];
		[alert addButtonWithTitle:text];
		[alert setAlertStyle:NSCriticalAlertStyle];  
		
		[alert beginSheetModalForWindow:errorWindow
						  modalDelegate:self
						 didEndSelector:@selector(continueRenaming:returnCode:contextInfo:)
							contextInfo:contextInfo];
	} else {
		[self continueRenaming:nil returnCode:0 contextInfo:contextInfo];
	}
}

- (void)continueRenaming:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)context
{	
	NSDictionary *contextInfo = context;
	
	BOOL		fileExtensionHidden			= [[contextInfo objectForKey:@"fileExtensionHidden"] boolValue];
	NSString	*oldExtension				= [contextInfo objectForKey:@"oldExtension"];
	NSString	*newExtension				= [contextInfo objectForKey:@"newExtension"];	
	BOOL		validOldExtension			= [[contextInfo objectForKey:@"validOldExtension"] boolValue];
	BOOL		validNewExtension			= [[contextInfo objectForKey:@"validNewExtension"] boolValue];
	NSString	*newName					= [contextInfo objectForKey:@"newName"];
	
	BOOL		useNewExtension = NO;
	
	if(returnCode == NSAlertSecondButtonReturn ||
	   [newExtension isCaseInsensitiveLike:oldExtension])
	{
		useNewExtension = YES;
	}
	
	// We may need to switch the extensions from new to old
	if(validOldExtension && validNewExtension && returnCode == NSAlertFirstButtonReturn)
	{
		newName = [newName stringByReplacingOccurrencesOfString:newExtension
													 withString:oldExtension
														options:NSBackwardsSearch
														  range:NSMakeRange(0, [newName length])];
	}
	
	// The new display name
	NSString *newDisplayName = newName;
	
	// The new name may contain a trailing extension for internal renaming purposes
	if(fileExtensionHidden)
	{
		if(useNewExtension)
			newName = [newName stringByAppendingPathExtension:newExtension];
		else
			newName = [newName stringByAppendingPathExtension:oldExtension];
	}
	
	NSString *newPath = [[self parentDirectory] stringByAppendingPathComponent:newName];
	
	BOOL success;
	
	// handle capitalization change separately
	if([[self path] compare:newPath options:NSCaseInsensitiveSearch] == NSOrderedSame)
	{
		success = [self caseRenameToPath:newPath];
	}
	else
	{
		success = [fileManager movePath:[self path] toPath:newPath handler:self];
	}
	
	if (success)
	{		
		// update file details on self
		[self setPath:newPath];
		[self setDisplayName:newDisplayName];
		
		// Set attributes
		NSDictionary *fileAttributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:fileExtensionHidden]
																   forKey:NSFileExtensionHidden];
		
		[fileManager changeFileAttributes:fileAttributes
								   atPath:newPath];
		
		[nc postNotificationName:NNTaggableObjectUpdate object:self userInfo:nil];
	}
	
	[contextInfo release];
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
	NSString *newDestination = [[self parentDirectory] stringByAppendingPathComponent:newName];
	
	// Check if the new name contains a colon
	NSRange colonRange = [newName rangeOfString:@":"];
	if(colonRange.location != NSNotFound)
		return NO;
	
	return (![fileManager fileExistsAtPath:newDestination] || 
			([newDestination compare:[self path] options:NSCaseInsensitiveSearch] == NSOrderedSame));
}

#pragma mark file error handling
/* TODO
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
*/

#pragma mark spotlight comment integration
- (NSMutableSet*)loadTags
{
	// get the curent tagToFileWriter
	NNTagToFileWriter *tagToFileWriter = [[NNTagStoreManager defaultManager] tagToFileWriter];
	
	// use tagToFileWriter to read tags from Finder's Spotlight Comment
	NSArray *loadedTags = [tagToFileWriter readTagsFromFile:self
											creationOptions:NNTagsCreationOptionFull];
	
	return [NSMutableSet setWithArray:loadedTags];
}

#pragma mark file management helper
- (NSString *)destinationForNewFile:(NSString *)fileName
{
	NSString *managedRoot = [self pathForFiles];
	NSString *targetDir = managedRoot;
	NSString *destination;
	
	NSArray *sortedTags = [[NNTags sharedTags] tagsSortedByRating:[self tags] ascending:NO];
	
	for (NNTag *tag in sortedTags)
	{
		NSString *subdir = tag.name;
		targetDir = [targetDir stringByAppendingPathComponent:subdir];
		
		// If the subdir doesn't exist yet, create it and use it right away
		if ([fileManager fileExistsAtPath:targetDir] == NO) 
		{
			[fileManager createDirectoryAtPath:targetDir withIntermediateDirectories:YES attributes:nil error:NULL];
			break;
		}
		// and if it exists and contains at least a certain number of files, use it, too.
		// However, if a file with the very same name is present there, try not to use it and add
		// one more tag to try there.
		else if ([[fileManager contentsOfDirectoryAtPath:targetDir error:NULL] count] <= MANAGED_FOLDER_MAX_SUBDIR_SIZE)
		{
			NSString *potentialTargetFile = [targetDir stringByAppendingPathComponent:fileName];
			
			if (![fileManager fileExistsAtPath:potentialTargetFile] ||
				[targetDir isEqualToString:[self.path stringByDeletingLastPathComponent]])
				break;
		}
		
		// If this is the last tag and the folder has more than a certain number of files,
		// well, then use it. What else should we do? ;)
	}
	
	// Append file name
	destination = [targetDir stringByAppendingPathComponent:fileName];
	
	// The new destination equals the current one. Abort!
	if ([destination isEqualToString:[self path]])
	{
		return nil;
	}
	
	// If a file with the very same name already exists here, use an additional numbered subfolder
	if ([fileManager fileExistsAtPath:destination])
	{
		NSInteger i = 1;
		
		while (YES)
		{
			destination = [targetDir stringByAppendingFormat:@"/%i/", i];
			
			if ([fileManager fileExistsAtPath:destination] == NO) 
			{
				[fileManager createDirectoryAtPath:destination withIntermediateDirectories:YES attributes:nil error:NULL];
			}
			
			destination = [destination stringByAppendingPathComponent:fileName];
			
			if (![fileManager fileExistsAtPath:destination])
				break;
			
			i++;
		}		
	}
	
	return destination;
}

// Old implementation
/*- (NSString*)destinationForNewFileOld:(NSString*)fileName
{
	// check if main directory folder contains file
	// increment until directory is found/created where file can be place
	NSString *managedRoot = [self pathForFiles];
	NSString *destination;
	NSInteger i = 1;
	
	while (YES)
	{
		NSString *directory = [managedRoot stringByAppendingFormat:@"/%ld/",i];
		
		if ([fileManager fileExistsAtPath:directory] == NO) 
			[fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:NULL];
		
		destination = [directory stringByAppendingPathComponent:fileName];
		
		// if file doesn't exists in directory, use this one
		if (![fileManager fileExistsAtPath:destination])
			break;
		
		i++;
	}
	
	return destination;
}*/

- (NSString*)pathForFiles
{ 
	NSString *directory = [[NNTagStoreManager defaultManager] managedFolder];

	if ([fileManager fileExistsAtPath:directory] == NO) 
		[fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:NULL];
	
	return directory; 
}

- (BOOL)isInManagedHierarchy
{
	NSString *managedRoot = [self pathForFiles];
	return [[self path] hasPrefix:managedRoot];
}


#pragma mark Misc
- (NSDate *)creationDate
{
	NSString *standardizedPath = [path stringByStandardizingPath];
	
	NSFileManager *manager = [NSFileManager defaultManager];
	NSDictionary *fileAttributes = [manager fileAttributesAtPath:standardizedPath traverseLink:YES];
	
	return [fileAttributes objectForKey:NSFileCreationDate];
}

- (NSDate *)modificationDate
{
	NSString *standardizedPath = [path stringByStandardizingPath];
	
	NSFileManager *manager = [NSFileManager defaultManager];
	NSDictionary *fileAttributes = [manager fileAttributesAtPath:standardizedPath traverseLink:YES];
	
	return [fileAttributes objectForKey:NSFileModificationDate];
}

- (NSInteger)label
{
	CFURLRef	url;
	FSRef		fsRef;
	BOOL		ret;
	FSCatalogInfo	cinfo;
	
	// Get FSRef
	url = CFURLCreateWithFileSystemPath(NULL, (CFStringRef)path, kCFURLPOSIXPathStyle, FALSE);
	if (!url) {
		return -1;
	}
		
	ret = CFURLGetFSRef(url, &fsRef);
	CFRelease(url);
	
	// Get Finder flags
	if (ret && (FSGetCatalogInfo(&fsRef, kFSCatInfoFinderInfo, &cinfo, NULL, NULL, NULL) == noErr))
	{
		return (((FileInfo*)&cinfo.finderInfo)->finderFlags & kColor) >> kIsOnDesk;
	} else {
		return -1;
	}
}

- (unsigned long long)size
{
	BOOL isDirectory;
	
	NSString *filePath = [path stringByStandardizingPath];
	
	if([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory] && isDirectory)
	{
		// Self references a directory or a bundle
		
		unsigned long long theSize = 0;
		
		NSArray *subpaths = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:filePath error:nil];
		
		NSString *curFile;
		
		NSEnumerator *enumerator = [subpaths objectEnumerator];
		while(curFile = [enumerator nextObject])
		{
			NSString *curPath = [filePath stringByAppendingPathComponent:curFile];
			theSize += [self sizeForFileAtPath:curPath];
		}
		
		return theSize;
	} else {
		return [self sizeForFileAtPath:filePath];
	}
}

- (unsigned long long)sizeForFileAtPath:(NSString *)aPath
{
	aPath = [aPath stringByStandardizingPath];
	NSDictionary *fAttr = [[NSFileManager defaultManager] attributesOfItemAtPath:aPath error:nil];
	
	return [[fAttr objectForKey:NSFileSize] unsignedLongLongValue];
}

/*- (void)computeSizeThreaded
{
	NSString *filePath = [path stringByStandardizingPath];
	[self performSelectorInBackground:@selector(computeSizeForFileAtPath:) withObject:filePath];
}

- (void)computeSizeForFileAtPath:(NSString *)aPath
{
	unsigned long long size = 0;
	
	BOOL isDirectory;
	if([[NSFileManager defaultManager] fileExistsAtPath:aPath isDirectory:&isDirectory] && isDirectory)
	{
		// Self references a directory or a bundle		
		NSArray *subpaths = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:aPath error:nil];
		
		NSString *curFile;
		
		NSEnumerator *enumerator = [subpaths objectEnumerator];
		while(curFile = [enumerator nextObject])
		{
			NSString *curPath = [aPath stringByAppendingPathComponent:curFile];
			size += [self sizeForFileAtPath:curPath];
		}		
	} else {
		size = [self sizeForFileAtPath:aPath];
	}
	
	// Write to cache
	sizeCached = size;
	
	NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
	[userInfo setValue:[NSNumber numberWithUnsignedLongLong:size] forKey:@"size"];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:NNFileSizeChangeOperation
													    object:self
													  userInfo:userInfo];
}

- (unsigned long long)sizeForFileAtPath:(NSString *)aPath
{		
	NSString *filePath = [aPath stringByStandardizingPath];
	OSStatus err;
	
	FSRef fileRef;
	err = FSPathMakeRef((const UInt8 *)[filePath fileSystemRepresentation], &fileRef, NULL);
	if (err == noErr) {
		FSCatalogInfo catalogInfo;
		err = FSGetCatalogInfo(&fileRef, kFSCatInfoDataSizes, &catalogInfo, NULL, NULL, NULL);
		if (err == noErr)
		{
			// This is the data fork's size
			UInt64 logicalSize = catalogInfo.dataLogicalSize;
			
			// Is there a resource fork? If so, add its size to our logical file size
			NSInteger fd = open([filePath fileSystemRepresentation], O_RDONLY, 0);
			size_t size = fgetxattr(fd, "com.apple.ResourceFork", NULL, 0, 0, 0x00);
			close(fd);
			if(size != 4294967295)			// This seems to be a nil value ;)
			{
				logicalSize += size;
				//NSLog(@"rf %u", size);
			}

			return logicalSize;
		}
	}
	
	return 0;
}*/

- (NSDictionary*)readMetadataFromPath:(NSString*)filePath
{
	CFStringRef filePathRef = (CFStringRef)filePath;
	MDItemRef mdItem = MDItemCreate(NULL, filePathRef);
	NSDictionary* metadata = [self readMetadataFromMDItem:mdItem];
	CFRelease(mdItem);
	return metadata;
}

- (NSDictionary*)readMetadataFromMDItem:(MDItemRef)mdItem
{	
	// initialize metadata with default values
	NSArray *keys = [NSArray arrayWithObjects:
					 (id)kMDItemDisplayName,
					 (id)kMDItemKind,
					 (id)kMDItemContentType,
					 (id)kMDItemContentTypeTree,
					 (id)kMDItemLastUsedDate,nil];
	
	NSArray *defaultValues = [NSArray arrayWithObjects:
							  [[self path] lastPathComponent],
							  NSLocalizedStringFromTable(@"DOCUMENT", @"Global", nil),
							  @"public.item",
							  [NSArray arrayWithObject:@"public.item"],
							  [NSDate dateWithTimeIntervalSince1970:0.0],nil];
							  
							  
	NSMutableDictionary *metadata = [NSMutableDictionary dictionaryWithObjects:defaultValues
																	   forKeys:keys];

	CFDictionaryRef valuesRef = MDItemCopyAttributeList(mdItem,
														kMDItemDisplayName,
														kMDItemKind,
														kMDItemContentType,
														kMDItemContentTypeTree,
														kMDItemLastUsedDate);
	
	// valuesRef is NULL on failure - retry
	if (valuesRef == NULL)
	{
		NSInteger retries = 5;
		
		while (valuesRef == NULL && retries > 0) 
		{
			retries--;
			usleep(200000); // 0.2 secs
			
			valuesRef = MDItemCopyAttributeList(mdItem,
												kMDItemDisplayName,
												kMDItemKind,
												kMDItemContentType,
												kMDItemContentTypeTree,
												kMDItemLastUsedDate);
		}
	}
	
	if (valuesRef != NULL) 
	{
		// metadata could be read - put everything into dictionary
		NSDictionary* values = (NSDictionary*)valuesRef;
		
		// name
		NSString *displayNameTemp = [values objectForKey:(id)kMDItemDisplayName];
		
		if (displayNameTemp != nil) 
			[metadata setObject:displayNameTemp forKey:(id)kMDItemDisplayName];
		
		// kind
		NSString *kindTemp = [values objectForKey:(id)kMDItemKind];
		
		if (kindTemp != nil)
			[metadata setObject:kindTemp forKey:(id)kMDItemKind];
		
		// content type
		NSString *contentTypeTemp = [values objectForKey:(id)kMDItemContentType];
		
		if (contentTypeTemp != nil)
			[metadata setObject:contentTypeTemp forKey:(id)kMDItemContentType];
		
		// content type tree
		NSArray *contentTypeTreeTemp = [values objectForKey:(id)kMDItemContentTypeTree];
		
		if (contentTypeTreeTemp != nil)
			[metadata setObject:contentTypeTreeTemp forKey:(id)kMDItemContentTypeTree];
		
		// last used date
		NSDate *lastUsedDateTemp = [values objectForKey:(id)kMDItemLastUsedDate];
		
		if (lastUsedDateTemp != nil)
			[metadata setObject:lastUsedDateTemp forKey:(id)kMDItemLastUsedDate];
		
		CFRelease(valuesRef);
	}
	else 
	{
		lcl_log(lcl_cnntagging, lcl_vWarning, @"Could not read metadata for %@ - using default values",[self path]);
	}
	
	return metadata;		
}

- (void)moveToTrash:(BOOL)flag errorWindow:(NSWindow *)window
{	
	// Only trash if flag is YES
	if(!flag) return;
	
	// Move file to trash
	[[NSFileManager defaultManager] trashFileAtPath:[self path]];
	
	NSString *trashDir = [NSHomeDirectory() stringByAppendingPathComponent:@".Trash"];
	NSString *trashPath = [trashDir stringByAppendingPathComponent:[self filename]];
	
	[self setPath:trashPath];
	
	// Remove all tags from file	
	[self removeAllTags];
}

// Compatibility mode for NNQuery
- (id)valueForAttribute:(id)attribute
{
	if([attribute isEqualTo:(NSString*)kMDItemContentType]) return [self contentTypeIdentifier];
	if([attribute isEqualTo:(NSString*)kMDItemContentTypeTree]) return [self contentType];
	if([attribute isEqualTo:(NSString*)kMDItemDisplayName]) return [self displayName];
	if([attribute isEqualTo:(NSString*)kMDItemPath]) return [self path];
	if([attribute isEqualTo:(NSString*)kMDItemLastUsedDate]) return [self lastUsedDate];
	return nil;
}



@end
