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

#import <Cocoa/Cocoa.h>
#import "FMDatabase.h"
#import "FMResultSet.h"

#import "UKKQueue.h"

@class NNTagToFileWriter;
@class NNSecureTagToFileWriter;
@class NNTagToOpenMetaWriter;
@class NNTags;
@class NNTagDirectoryWriter;
@class NNSymlinkTagDirectoryWriter;

/**
This class is used to configure the way tags are stored 
 on files - in the finder spotlight comment and serves as database frontend.
 TagStoreManager also holds the directory paths
 the framework needs to store the tags/files/etc. The default  values can be 
 overwritten by using NSUserDefaults - TagStoreManager default settings are overridden.
 */
@interface NNTagStoreManager : NSObject
{
	NNTagToFileWriter				*tagToFileWriter;
	NSString						*tagPrefix;
	
	NNTagDirectoryWriter			*tagDirectoryWriter;
	
	NSUserDefaults					*userDefaults;
	NSDictionary					*taggingDefaults;
	
	NSInteger								updateCount;
	NSLock							*updateLock;
	
	FMDatabase						*tagDB;
}

/**
@return Default instance
 */
+ (NNTagStoreManager*)defaultManager;

/**
@return Current tagToFileWriter in use
 */
- (NNTagToFileWriter*)tagToFileWriter;

/**
@param writer Writer to switch to
 */
- (void)setTagToFileWriter:(NNTagToFileWriter*)writer;

/**
@return Current tag prefix to use
 */
- (NSString*)tagPrefix;

/**
@param prefix Tag prefix to use
 */
- (void)setTagPrefix:(NSString*)prefix;

/**
@return Current tagDirectoryWriter in use
 */
- (NNTagDirectoryWriter*)tagDirectoryWriter;

/**
@param writer Writer to switch to
 */
- (void)setTagDirectoryWriter:(NNTagDirectoryWriter*)writer;

//--
// sqlite stuff
//--
/**
 /** db is kept open.
 Punakea causes some sync issues then!
 TODO sqlite isn't quite the thing for the future
  
 @return FMDatabase instance
 */
- (FMDatabase*)db;

/**
 @return Array of NNTags read from the db
 */
- (NSMutableArray*)tagsFromSQLdb;

/**
 @param tags Tags to set the database to
 */
- (void)setSQLdbToTags:(NSMutableArray*)tags;

/**
this should be called whenever a tag is modified
so that the store manager watching the sqlite db
for modifications won't cause NNTags to reload all
tags from disk. I know it suxx .... big time!
 */
- (void)signalTagDBUpdate;

//--
// pref stuff
//--

/**
 @return Path to tag database
 */
- (NSString*)tagDBLocation;

/**
 @return YES if files should be managed, NO otherwise
 */
- (BOOL)managedFolderEnabled;

/**
 @return Path to managed files folder
 */
- (NSString*)managedFolder;

/**
 @return YES if tag structure should be created on disk, NO otherwise
 */
- (BOOL)tagsFolderEnabled;

/**
 @return Path to folder where the tag structure is created
 */
- (NSString*)tagsFolder;

/**
 @return Additional prefs as a dictionary
 */
- (NSDictionary *)taggingDefaults;

@end
