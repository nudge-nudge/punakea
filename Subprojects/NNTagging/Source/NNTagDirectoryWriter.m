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

#import "NNTagDirectoryWriter.h"

#import "lcl.h"

@interface NNTagDirectoryWriter (PrivateAPI)

- (BOOL)createSymlinkToFile:(NNFile*)file inDirectory:(NSString*)directory;

- (void)addFile:(NNFile*)file
	   withTags:(NSMutableArray*)tags
		  depth:(NSInteger)depth
		oldTags:(NSArray*)oldTags
	currentTags:(NSMutableArray*)currentTags
		cutlist:(NSMutableArray*)cutlist 
		symlink:(BOOL)isSymlink
oldTagsContainCurrentTags:(BOOL)oldTagsContainCurrentTags;

- (void)removeFile:(NNFile*)modifiedFile
		  withTags:(NSMutableArray*)tags
	   removedTags:(NSMutableArray*)removedTags
	   currentTags:(NSMutableArray*)currentTags
		   cutlist:(NSMutableArray*)cutlist
containsRemovedTag:(BOOL)containsRemovedTag;


- (BOOL)createDirectoryForTags:(NSMutableArray*)tags containingFile:(NNFile*)file;
- (BOOL)createSymlinkForTags:(NSMutableArray*)tags;
- (NSString*)tagsToDirectoryString:(NSArray*)tags;
- (BOOL)array:(NSArray*)a isSubsetOfArray:(NSArray*)b;
- (BOOL)externalLinksInDirectory:(NSString*)directory;

- (BOOL)makeDirectoryWritable:(NSString*)directory;
- (BOOL)makeDirectoryReadOnly:(NSString*)directory;

- (NSInteger)depth;

@end

@implementation NNTagDirectoryWriter

#pragma mark init
- (id)init
{
	if (self = [super init])
	{
		fileManager = [NSFileManager defaultManager];
		
		writableDirectoryAttributes = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObject:[NSNumber numberWithLong:448]]
																	forKeys:[NSArray arrayWithObject:NSFilePosixPermissions]];
																					
		
		readonlyDirectoryAttributes = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObject:[NSNumber numberWithLong:360]]
																	forKeys:[NSArray arrayWithObject:NSFilePosixPermissions]];
	}
	return self;
}

#pragma mark functionality
- (void)createDirectoryStructureForTaggableObject:(NNTaggableObject*)taggableObject withOldTags:(NSArray*)oldTags
{
	// only NNFiles get a directory structure
	if (![taggableObject isKindOfClass:[NNFile class]])
		return;
	
	NNFile *file = (NNFile*)taggableObject;
	
	// tagged directories are also ignored, except for bundles
	// COMMENT THIS OUT IF SYMNLINKS TO TAGGED FOLDERS SHOULD BE GENERATED
	if ([file isDirectory] && ![[NSWorkspace sharedWorkspace] isFilePackageAtPath:[file path]])
		return;	
	
	// create new autorelease pool - otherwise, too much memory accumulates
	NSAutoreleasePool *tempPool = [[NSAutoreleasePool alloc] init];
	
	NSArray *tags = [[file tags] allObjects];
	
	// no directories will be created for files without tags
	if ([tags count] == 0 && [oldTags count] == 0)
		return;
	
	NSMutableArray *tagNames = [NSMutableArray array];
	
	for (NNTag *tag in tags)
		[tagNames addObject:[tag name]];
	
	// dfs only works with sorted names
	[tagNames sortUsingSelector:@selector(compare:)];
	
	NSMutableArray *oldTagNames = [NSMutableArray array];
	
	for (NNTag *tag in oldTags)
		[oldTagNames addObject:[tag name]];
	
	[oldTagNames sortUsingSelector:@selector(compare:)];
	
	// determine if tags have been added, removed or changed
	if ([tags count] > [oldTags count])
	{
		// tags have been added	
		[self addFile:file
			 withTags:tagNames
				depth:[self depth]
			  oldTags:oldTagNames
		  currentTags:[NSMutableArray array]
			  cutlist:[NSMutableArray array]
			  symlink:NO
	oldTagsContainCurrentTags:([oldTags count] == 0)];
	}
	else if ([tags count] < [oldTags count])
	{
		// tags have been removed
		NSMutableArray *removedTags = [NSMutableArray arrayWithArray:oldTagNames];
		[removedTags removeObjectsInArray:tagNames];
		
		[self removeFile:file
				withTags:oldTagNames
			 removedTags:removedTags
			 currentTags:[NSMutableArray array]
				 cutlist:[NSMutableArray array]
	  containsRemovedTag:NO];
	}
	else
	{
		// count is equal, a tag has changed
		
		// first, find tag which changed into what
		NSMutableArray *changedTagToRemove = [NSMutableArray arrayWithArray:oldTagNames];
		[changedTagToRemove removeObjectsInArray:tagNames];
		
		// there can be only one tag change at a time
		// - remove changedTagsToRemove
		[self removeFile:file
				withTags:oldTagNames
			 removedTags:changedTagToRemove
			 currentTags:[NSMutableArray array]
				 cutlist:[NSMutableArray array]
	  containsRemovedTag:NO];
	
		// remove changedTagToRemove from oldTagNames
		// this will be the current directory distribution
		[oldTagNames removeObjectsInArray:changedTagToRemove];
		
		[self addFile:file
			 withTags:tagNames
				depth:[self depth]
			  oldTags:oldTagNames
		  currentTags:[NSMutableArray array]
			  cutlist:[NSMutableArray array]
			  symlink:NO
oldTagsContainCurrentTags:([oldTags count] == 0)];
	}
	
	// release current autorelease pool
	[tempPool release];
}

- (BOOL)createSymlinkToFile:(NNFile*)file inDirectory:(NSString*)directory
{
	[self doesNotRecognizeSelector:_cmd];
	return NO;
}

#pragma mark dfs
/**
 Depth-first traversal of the tag tree to create folder structure for tagset. 


@param tags							List of remaining tags to use.
@param depth						Remaining depth in tree traversal.
@param oldtags						Previously assigned tags.
@param currentTags					Current tag combination.
@param cutlist						List of tags that cause a tree cutoff.
@param symlink						YES if 'currentTags' specifies a symlink, NO if 'currentTags' specifies a directory.
@param oldTagsContainCurrentTags	YES if all tags in currentTags are contained in oldtags, else NO.
*/
- (void)addFile:(NNFile*)file
	   withTags:(NSMutableArray*)tags
		  depth:(NSInteger)depth
		oldTags:(NSArray*)oldTags
	currentTags:(NSMutableArray*)currentTags
		cutlist:(NSMutableArray*)cutlist 
		symlink:(BOOL)isSymlink
oldTagsContainCurrentTags:(BOOL)oldTagsContainCurrentTags;
{
	// do not create anything at the root level
	if ([currentTags count] != 0 && !oldTagsContainCurrentTags)
	{
		if (isSymlink)
		{
			[self createSymlinkForTags:currentTags];
		}
		else
		{
			[self createDirectoryForTags:currentTags containingFile:file];
		}
	}
	
	// stop if max depth is reached
	if (depth == 0 || isSymlink)
		return;
	
	NSMutableArray *cutoff = [NSMutableArray arrayWithArray:cutlist];
	
	for (NSString *tag in tags)
	{
		NSMutableArray *remainingTags = [NSMutableArray arrayWithArray:tags];
		[remainingTags removeObject:tag];
		
		oldTagsContainCurrentTags = oldTagsContainCurrentTags && [oldTags containsObject:tag];
		
		[currentTags addObject:tag];
		
		if ([cutlist containsObject:tag])
		{
			[self addFile:file
				 withTags:remainingTags
					depth:depth-1
				  oldTags:oldTags
			  currentTags:currentTags
				  cutlist:cutoff
				  symlink:YES
oldTagsContainCurrentTags:oldTagsContainCurrentTags];
		}
		else
		{
			[self addFile:file
				 withTags:remainingTags
					depth:depth-1
				  oldTags:oldTags
			  currentTags:currentTags
				  cutlist:cutoff
				  symlink:NO
oldTagsContainCurrentTags:oldTagsContainCurrentTags];
			
			[cutoff addObject:tag];
		}
		
		[currentTags removeLastObject];
	}
}

/**
Depth-first traversal of the tag tree to delete the tags in removedTags for the given file
in the folder structure.

@param modifiedFile					File with modified tagset.
@param tags							List of all tags on the file.
@param removedTags					List of tags removed from the file.
@param currentTags					Current tag combination.
@param cutlist						List of tags that cause a tree cutoff.
@param containsRemovedTag			True iff a removed tag is contained in currentTags.
*/
- (void)removeFile:(NNFile*)modifiedFile
		  withTags:(NSMutableArray*)tags
	   removedTags:(NSMutableArray*)removedTags
	   currentTags:(NSMutableArray*)currentTags
		   cutlist:(NSMutableArray*)cutlist
containsRemovedTag:(BOOL)containsRemovedTag
{	
	// do not go deeper than the max depth of addFile
	if ((NSInteger)[currentTags count] > [self depth])
		return;
	
	NSError *error = nil;
	BOOL success;
	
	NSString *tagsFolder = [[NNTagStoreManager defaultManager] tagsFolder];
	NSString *d = [tagsFolder stringByAppendingPathComponent:[self tagsToDirectoryString:currentTags]];
	
	// clean up dead links
	if ([currentTags count] != 0)
	{
		for (NSString *file in [fileManager contentsOfDirectoryAtPath:d error:&error])
		{
			// if file is a dead symbolic link, remove it
			NSString *pathToFile = [d stringByAppendingPathComponent:file];
			
			// only look at symlinks
			if (![fileManager isSymbolicLinkAtPath:pathToFile])
				continue;
			
			NSString *destination = [fileManager destinationOfSymbolicLinkAtPath:pathToFile error:&error];
			
			if (destination && ![fileManager fileExistsAtPath:destination])
			{
				// make parent dir writable
				[self makeDirectoryWritable:d];
				
				success = [fileManager removeItemAtPath:pathToFile error:&error];
				
				if (!success)
				{
					lcl_log(lcl_cnntagging,lcl_vError,@"Error removing file '%@': %@",pathToFile,[error localizedDescription]);
				}
				
				// reset to readonly
				[self makeDirectoryReadOnly:d];
			}
		}
	}
	
	// update containsRemovedTag
	containsRemovedTag = NO;
	
	for (NNTag* tag in currentTags)
	{
		if ([removedTags containsObject:tag])
		{
			containsRemovedTag = YES;
			break;
		}
	}
	
	// remove all symbolic links for the file
	if (containsRemovedTag)
	{
		NSString *linkFile;
		
		BOOL exists = [fileManager symlinkExistsForFile:[modifiedFile path]
											inDirectory:d
												 atPath:&linkFile];
		
		if (exists)
		{
			// make parent dir writable
			[self makeDirectoryWritable:d];
			
			success = [fileManager removeItemAtPath:linkFile error:&error];
			
			if (!success)
			{
				lcl_log(lcl_cnntagging,lcl_vError,@"Error removing file '%@': %@",linkFile,[error localizedDescription]);
			}
			
			// reset to readonly
			[self makeDirectoryReadOnly:d];
		}
	}
	
	// no more external links in this directory -> obsolete
	if (containsRemovedTag && ![self externalLinksInDirectory:d])
	{
		// make dir and parent dir writable
		NSString *parentDir = [d stringByDeletingLastPathComponent];
		[self makeDirectoryWritable:parentDir];
		[self makeDirectoryWritable:d];
		
		// make all subdirs writable (needed for recursive remove)
		NSEnumerator *dirEnum = [fileManager enumeratorAtPath:d];
		NSString *subdir;
		
		while (subdir = [dirEnum nextObject])
		{
			if (![fileManager isSymbolicLinkAtPath:[d stringByAppendingPathComponent:subdir]])
				[self makeDirectoryWritable:[d stringByAppendingPathComponent:subdir]];
		}
		
		// remove dir including all subdirs
		success = [fileManager removeItemAtPath:d error:&error];

		if (!success)
		{
			lcl_log(lcl_cnntagging,lcl_vError,@"Error removing directory '%@': %@",d,[error localizedDescription]);
		}
		
		// reset to readonly
		[self makeDirectoryReadOnly:parentDir];
		
		return;
	}
	
	// DFS traversal
	NSMutableArray *cutoff = [NSMutableArray arrayWithArray:cutlist];
	for (NNTag* tag in tags)
	{
		NSMutableArray *remainingTags = [NSMutableArray arrayWithArray:tags];
		[remainingTags removeObject:tag];
		
		[currentTags addObject:tag];
		
		// symlinks are cleaned up before, so only recurse for real dirs
		if (![cutlist containsObject:tag])
		{
			[self removeFile:modifiedFile
					withTags:remainingTags
				 removedTags:removedTags
				 currentTags:currentTags
					 cutlist:cutoff
		  containsRemovedTag:(containsRemovedTag || [removedTags containsObject:tag])];
			[cutoff addObject:tag];
		}
		
		[currentTags removeLastObject];
	}
}

- (BOOL)createDirectoryForTags:(NSMutableArray*)tags containingFile:(NNFile*)file
{	
	NSString *directory = [self tagsToDirectoryString:tags];
	NSString *newDir = [[[NNTagStoreManager defaultManager] tagsFolder] stringByAppendingString:directory];
	
	NSError *error;
	BOOL success = YES;
	BOOL isDirectory;
	
	if (![fileManager fileExistsAtPath:newDir isDirectory:&isDirectory])
	{
		NSString *parentDir = [newDir stringByDeletingLastPathComponent];
		
		// make sure the parent directory is writable
		if (![fileManager isWritableFileAtPath:newDir])
			success = success && [self makeDirectoryWritable:parentDir];
		
		// create new directory
		success = success && [fileManager createDirectoryAtPath:newDir
									withIntermediateDirectories:YES
													 attributes:writableDirectoryAttributes
														  error:&error];
		
		if (!success)
		{
			lcl_log(lcl_cnntagging,lcl_vError,@"Error creating directory '%@', %@",newDir,[error localizedDescription]);
		}
		
		// make parent-dir read-only
		success = success && [self makeDirectoryReadOnly:parentDir];
	}
	else if (!isDirectory)
	{
		lcl_log(lcl_cnntagging,lcl_vError,@"Error while creating the tag directory: '%@' is not a directory",newDir);
		return NO;
	}
	else
	{
		// make sure the directory is writable, which it will not be
		// if it has not just been created
		success = success && [self makeDirectoryWritable:newDir];
	}
	
	success = success && [self createSymlinkToFile:file inDirectory:[newDir stringByAppendingString:@"/"]];
	
	// set dir to be read-only
	success = success && [self makeDirectoryReadOnly:newDir];
	
	return success;
}

- (BOOL)createSymlinkForTags:(NSMutableArray*)tags
{
	NSString *directory = [self tagsToDirectoryString:tags];
	NSString *newDir = [[[NNTagStoreManager defaultManager] tagsFolder] stringByAppendingString:directory];

	// sort tags to get target
	NSArray *sorted = [tags sortedArrayUsingSelector:@selector(compare:)];
	NSString *target = [self tagsToDirectoryString:sorted];
	NSString *newTarget = [[[NNTagStoreManager defaultManager] tagsFolder] stringByAppendingString:target];
		
	BOOL success = YES;
	
	if (![fileManager fileExistsAtPath:newDir])
	{
		NSString *parentDir = [newDir stringByDeletingLastPathComponent];
		
		// make sure the directory is writable
		if (![fileManager isWritableFileAtPath:newDir])
			success = success && [self makeDirectoryWritable:parentDir];
		
		// create symlink
		success = success && [fileManager createSymbolicLinkAtPath:newDir
														pathContent:newTarget];
		
		// make parent-dir read-only
		success = success && [self makeDirectoryReadOnly:parentDir];
	}
	return success;
}
			
// Returns YES iff specified directory contains 
// at least one external link. (Not to a tag folder)
- (BOOL)externalLinksInDirectory:(NSString*)directory;
{
	NSArray *pathContent = [fileManager contentsOfDirectoryAtPath:directory error:NULL];
	
	for (NSString* file in pathContent)
	{
		NSString *fullPath = [directory stringByAppendingPathComponent:file];
		
		if ([fileManager isSymbolicLinkAtPath:fullPath])
		{
			NSString *destination = [fileManager destinationOfSymbolicLinkAtPath:fullPath error:NULL];
	
			// if any link has its target outside the tagFolder, return yes
			if (![destination hasPrefix:[[NNTagStoreManager defaultManager] tagsFolder]])
				return YES;
			
		}
	}
	return NO;
}

- (NSString*)tagsToDirectoryString:(NSArray*)tags
{
	NSString *directoryString = [tags componentsJoinedByString:@"/"];
	return directoryString;
}
				
- (BOOL)array:(NSArray*)a isSubsetOfArray:(NSArray*)b
{
	for (id obj in a)
	{
		if (![b containsObject:obj])
			return NO;
	}
	
	return YES;
}

- (BOOL)makeDirectoryWritable:(NSString*)directory
{
	NSError *error;
	BOOL success = [fileManager setAttributes:writableDirectoryAttributes
								 ofItemAtPath:directory
										error:&error];
	
	if (!success)
	{
		lcl_log(lcl_cnntagging,lcl_vError,@"Could not make directory '%@' writable: %@",directory,[error localizedDescription]);
	}
	
	return success;
}

- (BOOL)makeDirectoryReadOnly:(NSString*)directory
{
	NSError *error;
	BOOL success = [fileManager setAttributes:readonlyDirectoryAttributes
								 ofItemAtPath:directory
										error:&error];
	
	if (!success)
	{
		lcl_log(lcl_cnntagging,lcl_vError,@"Could not make directory '%@' read-only: %@",directory,[error localizedDescription]);
	}
	
	return success;
}

#pragma mark Accessors
- (NSInteger)depth
{	
	NSString *key = @"ManageFiles.TagsFolder.Depth";
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:key])
		return [[NSUserDefaults standardUserDefaults] integerForKey:key];
	else
		return [[[[NNTagStoreManager defaultManager] taggingDefaults] objectForKey:key] integerValue];
}

@end
