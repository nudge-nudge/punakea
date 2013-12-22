// Copyright (c) 2006-2013 nudge:nudge (Johannes Hoffart & Daniel BŠr). All rights reserved.
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

#import "NNTagStoreManager.h"

#import "NNTagToFileWriter.h"
#import "NNSecureTagToFileWriter.h"
#import "NNTagToOpenMetaWriter.h"
#import "NNTags.h"
#import "NNTagDirectoryWriter.h"
#import "NNSymlinkTagDirectoryWriter.h"

#import "lcl.h"

@interface NNTagStoreManager (PrivateAPI)

- (FMDatabase*)openDB;

@end

@implementation NNTagStoreManager

//this is where the sharedInstance is held
static NNTagStoreManager *sharedInstance = nil;

//constructor - only called by sharedInstance
- (id)sharedInstanceInit {
	if (self = [super init])
	{
		NNTagToFileWriter *writer = [[NNTagToOpenMetaWriter alloc] init];
		[self setTagToFileWriter:writer];
		[writer release];
		[self setTagPrefix:@"@"];
		
		NNTagDirectoryWriter *dirWriter = [[NNSymlinkTagDirectoryWriter alloc] init];
		[self setTagDirectoryWriter:dirWriter];
		[dirWriter release];
		
		userDefaults = [NSUserDefaults standardUserDefaults];
			
		NSString *path = [[NSBundle bundleWithIdentifier:@"eu.nudgenudge.nntagging"] pathForResource:@"Settings" ofType:@"plist"];
		taggingDefaults = [[NSDictionary alloc] initWithContentsOfFile:path];

		// watch sql db for changes
		// this is needed to sync the db to outside apps
		UKKQueue *queue = [UKKQueue sharedFileWatcher];
		[queue addPath:[self tagDBLocation]];
		[queue setDelegate:self];
		updateCount = 0;
		updateLock = [[NSLock alloc] init];
		
		// open the db
		tagDB = [[self openDB] retain];
	}
	return self;
}

#pragma mark accessors
- (NNTagToFileWriter*)tagToFileWriter
{
	return tagToFileWriter;
}

- (void)setTagToFileWriter:(NNTagToFileWriter*)writer
{
	[tagToFileWriter release];
	tagToFileWriter = [writer retain];
}

- (NSString*)tagPrefix
{
	return tagPrefix;
}

- (void)setTagPrefix:(NSString*)prefix
{
	[tagPrefix release];
	tagPrefix = [prefix retain];
}

- (NNTagDirectoryWriter*)tagDirectoryWriter
{
	return tagDirectoryWriter;
}

- (void)setTagDirectoryWriter:(NNTagDirectoryWriter*)writer;
{
	[tagDirectoryWriter release];
	tagDirectoryWriter = [writer retain];
}

- (NSDictionary *)taggingDefaults
{
	return taggingDefaults;
}


#pragma mark sqlite
// creates DB if necessary
- (FMDatabase*)openDB
{
	BOOL success = YES;
	
	FMDatabase *db = nil;
	
	NSFileManager *fm = [NSFileManager defaultManager];
	
	NSString *dbLocation = [self tagDBLocation];
	
	// create DB if there is none
	if (![fm fileExistsAtPath:dbLocation])
	{
		// create parent dir
		NSString *parentDir = [dbLocation stringByDeletingLastPathComponent];
		
		if (![fm fileExistsAtPath:parentDir])
		{
			success = [fm createDirectoryAtPath:parentDir
					withIntermediateDirectories:YES
									 attributes:nil
										  error:NULL];
			
			if (!success)
				lcl_log(lcl_cnntagging,lcl_vError,@"Tag database could not be created, make sure '%@' is a writable directory",parentDir);
		}
		
		db = [[FMDatabase alloc] initWithPath:dbLocation];
		
		// open db
		success = success && [db open];
		
		// create initial tables
		success = success && [db executeUpdate:@"CREATE TABLE tags (class text, name text, query text, lastClicked date, lastUsed date, clickCount long, useCount long)",nil];
	}
	else
	{
		// just create the db instance
		db = [[FMDatabase alloc] initWithPath:dbLocation];
		
		// open db
		success = success && [db open];
	}
		 
	 return [db autorelease];
}

- (FMDatabase*)db
{
	return tagDB;
}

- (NSMutableArray*)tagsFromSQLdb
{
	NSMutableArray *loadedTags = [NSMutableArray array];
	
	FMDatabase *db = [self db];	
	FMResultSet *rs = [db executeQuery:@"SELECT * FROM tags"];
	
	while ([rs next])
	{
		NSString *class = [rs stringForColumn:@"class"];
	
		if ([class isEqualToString:@"NNSimpleTag"])
		{
			NNSimpleTag *simpleTag = [[NNSimpleTag alloc] initWithName:[rs stringForColumn:@"name"]
																 query:[rs stringForColumn:@"query"]
														   lastClicked:[rs dateForColumn:@"lastClicked"]
															  lastUsed:[rs dateForColumn:@"lastUsed"]
															clickCount:[rs longForColumn:@"clickCount"]
															  useCount:[rs longForColumn:@"useCount"]];
			[loadedTags addObject:simpleTag];
			[simpleTag release];
		}
	}
	
	return loadedTags;
}   

- (void)setSQLdbToTags:(NSMutableArray*)tags
{
	FMDatabase *db = [self db];
	[db beginTransaction];
	
	// clean table
	[db executeUpdate:@"DELETE FROM tags",nil];
	
	// write all current tags to the table	
	for (NNTag *tag in tags)
	{
		[db executeUpdate:@"INSERT INTO tags VALUES (?, ?, ?, ?, ?, ?, ?)",
		 [tag class], [tag name], [tag query],
		 [tag lastClicked], [tag lastUsed],
		 [NSNumber numberWithUnsignedLong:[tag clickCount]], [NSNumber numberWithUnsignedLong:[tag useCount]], nil];
	}
	
	// signal imminent db change
	[self signalTagDBUpdate];
	
	[db commit];
}

- (void)signalTagDBUpdate
{
	[updateLock lock];
	updateCount++;
	[updateLock unlock];
}

#pragma mark preferences

- (NSString*)tagDBLocation
{
	NSString *location = [userDefaults stringForKey:@"General.TagDB.Location"];
	
	if (!location)
	{
		//use defaults from settings
		location = (NSString*)[taggingDefaults objectForKey:@"General.TagDB.Location"]; 
	}
	
	return [location stringByExpandingTildeInPath];
}
	
- (BOOL)managedFolderEnabled
{
	if ([userDefaults objectForKey:@"ManageFiles.ManagedFolder.Enabled"])
	{
		return [userDefaults boolForKey:@"ManageFiles.ManagedFolder.Enabled"];
	}
	else
	{
		//use defaults from settings
		id value = [taggingDefaults objectForKey:@"ManageFiles.ManagedFolder.Enabled"];
		return [(NSNumber*)value boolValue];
	}
}
		
- (NSString*)managedFolder
{
	NSString *location = [userDefaults stringForKey:@"ManageFiles.ManagedFolder.Location"];
	
	if (!location)
	{
		//use defaults from settings
		location = (NSString*)[taggingDefaults objectForKey:@"ManageFiles.ManagedFolder.Location"]; 
	}
		
	return [[location stringByExpandingTildeInPath] stringByAppendingString:@"/"];
}

- (BOOL)tagsFolderEnabled
{
	if ([userDefaults objectForKey:@"ManageFiles.TagsFolder.Enabled"])
	{
		return [userDefaults boolForKey:@"ManageFiles.TagsFolder.Enabled"];
	}
	else
	{
		//use defaults from settings
		id value = [taggingDefaults objectForKey:@"ManageFiles.TagsFolder.Enabled"];
		return [(NSNumber*)value boolValue];
	}
}

- (NSString*)tagsFolder
{
	NSString *location = [userDefaults stringForKey:@"ManageFiles.TagsFolder.Location"];
	
	if (!location)
	{
		//use defaults from settings
		location = (NSString*)[taggingDefaults objectForKey:@"ManageFiles.TagsFolder.Location"]; 
	}
	
	return [[location stringByResolvingSymlinksInPath] stringByAppendingString:@"/"];
}

#pragma mark kqueue delegate
// gets called when sqlite tag db is modified
-(void) watcher: (id<UKFileWatcher>)kq receivedNotification: (NSString*)nm forPath: (NSString*)fpath
{
	// everything except writes to the file can be igored
	if (![nm isEqualToString:UKFileWatcherWriteNotification])
		return;
	
	// check if the update has been made by the running app or not
	// updatecount contains number of pending file changes
	// caused by app
	[updateLock lock];
	updateCount--;
	
	if (updateCount < 0)
	{
		updateCount++;
		[[NNTags sharedTags] syncFromDB];
	}
	
	[updateLock unlock];
}

#pragma mark singleton stuff
+ (NNTagStoreManager*)defaultManager {
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

- (NSUInteger)retainCount {
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}
		
@end
