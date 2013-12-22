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

#import "NNCompatbilityChecker.h"

#import "lcl.h"

@interface NNCompatbilityChecker (PrivateAPI)

/**
 @return Path to (old) tags.plist
 */
- (NSString*)pathToPlist;

- (void)updateTo02:(NSMutableString*)content;
- (void)switchTagStorageToSQLite;
- (void)migrateSpotlightCommentsToOpenMeta;
- (void)upgradeOpenMetaToKMDItemOM;

@end

@implementation NNCompatbilityChecker

#pragma mark accessors
- (NSString*)pathToPlist
{
	NSString *fileName = @"tags.plist"; 
	
	NSString *folder = [NSString stringWithFormat:@"~/Library/Application Support/Punakea/"];
	folder = [folder stringByExpandingTildeInPath]; 
	
	return [folder stringByAppendingPathComponent:fileName]; 
}

#pragma mark functionality
- (void)update
{
	if ([[NSFileManager defaultManager] fileExistsAtPath:[self pathToPlist]])
	{
		NSError *error;
		
		NSMutableString *content = [NSMutableString stringWithContentsOfFile:[self pathToPlist] encoding:NSUTF8StringEncoding error:&error];
		
		if (!content)
		{
			// there has been a problem reading the old plist
			lcl_log(lcl_cnntagging,lcl_vError,@"Error (%@) opening tag database for conversion",[error localizedDescription]);
		}
	
		// Punakea 0.1x -> 0.2
		[self updateTo02:content];
		
		BOOL success = [content writeToFile:[self pathToPlist] atomically:YES encoding:NSUTF8StringEncoding error:&error];
		
		if (!success)
		{
			// there has been a problem reading the old plist
			lcl_log(lcl_cnntagging,lcl_vError,@"Error (%@) writing tag database for conversion",[error localizedDescription]);
		}
		
		// Punakea 0.3x -> 0.4
		[self switchTagStorageToSQLite];
	}
	
	// For compatibility with old OpenMeta apps (remove this sometime!)
	[self upgradeOpenMetaToKMDItemOM];
}

- (void)updateTo02:(NSMutableString*)content
{
	/*
	 updates PASimpleTag and PATag to NNSimpleTag and NNTag
	 neccesary because of renaming classes.
	 upgrades 0.12 -> 0.2
	 */
	if (!NSEqualRanges([content rangeOfString:@"PATag"],NSMakeRange(NSNotFound,0)))
	{
		// create backup
		NSString *backupPath = [[self pathToPlist] stringByAppendingPathExtension:@"v012"];
		[[NSFileManager defaultManager] copyPath:[self pathToPlist] toPath:backupPath handler:NULL];
		
		// replace PA(Simple)Tag with NN(SimpleTag)
		NSRange notFound = NSMakeRange(NSNotFound,0);
		
		// first replace PATag
		NSRange foundRange = [content rangeOfString:@"PATag"];
		
		while (!NSEqualRanges(foundRange,notFound))
		{
			[content replaceCharactersInRange:foundRange withString:@"NNTag"];
			foundRange = [content rangeOfString:@"PATag"];
		}
		
		foundRange = [content rangeOfString:@"PASimpleTag"];
		
		while (!NSEqualRanges(foundRange,notFound))
		{
			[content replaceCharactersInRange:foundRange withString:@"NNSimpleTag"];
			foundRange = [content rangeOfString:@"PASimpleTag"];
		}
		
		lcl_log(lcl_cnntagging,lcl_vInfo,@"Updated tag storage to v0.2 format");
	}
}

// SQLite switch: write tags.plist to sqlite db
- (void)switchTagStorageToSQLite
{
	NSString *path = [self pathToPlist];
	NSMutableData *data = [NSData dataWithContentsOfFile:path];
	
	if (data)
	{
		NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
		NSMutableDictionary *rootObject = [unarchiver decodeObject];
		[unarchiver finishDecoding];
		[unarchiver release];
		
		NSMutableArray *loadedTags = [rootObject valueForKey:@"tags"];
		
		// create sqlite db
		FMDatabase *db = [[NNTagStoreManager defaultManager] db];
		
		[db beginTransaction];
		
		for (NNTag *tag in loadedTags)
		{
			[db executeUpdate:@"INSERT INTO tags VALUES (?, ?, ?, ?, ?, ?, ?)",
			 [tag class], [tag name], [tag query],
			 [tag lastClicked], [tag lastUsed],
			 [NSNumber numberWithUnsignedLong:[tag clickCount]], [NSNumber numberWithUnsignedLong:[tag useCount]], nil];
		}
		
		[db commit];
	}
	else
	{
		// there was no tags plist, nothing to do
	}
	
	NSError *error;
	
	NSString *backupLocation = [path stringByAppendingString:@".bak"];
	BOOL success = [[NSFileManager defaultManager] moveItemAtPath:path toPath:backupLocation error:&error];
	
	if (!success)
	{
		lcl_log(lcl_cnntagging,lcl_vError,@"Could not move '%@': %@",path,[error localizedDescription]);
	}
}

- (void)upgradeOpenMetaToKMDItemOM {
	[OpenMetaBackup upgradeOpenMetaTokMDItemOM];
}

@end
