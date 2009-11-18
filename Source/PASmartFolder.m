//
//  PASmartFolder.m
//  punakea
//
//  Created by Daniel on 30.03.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PASmartFolder.h"


@implementation PASmartFolder

+ (NSString *)smartFolderFilenameForTag:(NNTag *)tag
{
	NSMutableDictionary *sf = [NSMutableDictionary dictionary];
	[sf setObject:[NSNumber numberWithInteger:1] forKey:@"CompatibleVersion"];
	
	NSString *rawQuery = [NSString stringWithFormat:@"(((%@))) &amp;&amp; (true)",[tag query]];
	[sf setObject:rawQuery forKey:@"RawQuery"];
	
	NSMutableDictionary *rawQueryDict = [NSMutableDictionary dictionary];
	[rawQueryDict setObject:[NSNumber numberWithBool:YES] forKey:@"FinderFilesOnly"];
	[rawQueryDict setObject:rawQuery forKey:@"RawQuery"];
	[rawQueryDict setObject:[NSArray arrayWithObject:@"kMDQueryScopeComputer"] forKey:@"SearchScopes"];
	[rawQueryDict setObject:[NSNumber numberWithBool:YES] forKey:@"UserFilesOnly"];
	[sf setObject:rawQueryDict forKey:@"RawQueryDict"];
	
	// Search criteria are needed for editing the folder later on in Finder
	NSMutableDictionary *searchCriteria = [NSMutableDictionary dictionary];
	
	[searchCriteria setObject:@"" forKey:@"AnyAttributeContains"];
		
	NSString *currentFolderPath = @"~";
	NSMutableArray *currentFolderPathArray = [NSMutableArray arrayWithObject:[currentFolderPath stringByExpandingTildeInPath]];
	[searchCriteria setObject:currentFolderPathArray forKey:@"CurrentFolderPath"];
	
	[searchCriteria setObject:[NSNumber numberWithLongLong:1396926573] forKey:@"FXScope"];
	
	NSMutableArray *scopeArrayOfPaths = [NSMutableArray arrayWithObject:@"kMDQueryScopeComputer"];
	[searchCriteria setObject:scopeArrayOfPaths forKey:@"FXScopeArrayOfPaths"];
	
	NSMutableDictionary *criteriaSlice = [NSMutableDictionary dictionary];
	
	NSMutableArray *criteria = [NSMutableArray array];
	[criteria addObject:@"kOMUserTags"];
	[criteria addObject:[NSNumber numberWithInteger:103]];
	[criteria addObject:[NSNumber numberWithInteger:104]];
	[criteriaSlice setObject:criteria forKey:@"criteria"];
	
	NSMutableArray *displayValues = [NSMutableArray array];
	[displayValues addObject:@"Tags"];
	[displayValues addObject:@"is"];
	[displayValues addObject:[NSString stringWithFormat:@"%@",[tag name]]];
	[criteriaSlice setObject:displayValues forKey:@"displayValues"];
	
	[criteriaSlice setObject:[NSNumber numberWithInteger:0] forKey:@"rowType"];
	[criteriaSlice setObject:[NSArray array] forKey:@"subrows"];
	
	NSMutableArray *criteriaSlices = [NSMutableArray arrayWithObject:criteriaSlice];
	[searchCriteria setObject:criteriaSlices forKey:@"FXCriteriaSlices"];
	
	[sf setObject:searchCriteria forKey:@"SearchCriteria"];
	
	// Output file to temp dir
	NSString *filename = NSTemporaryDirectory();
	filename = [filename stringByAppendingPathComponent:[tag name]];
	filename = [filename stringByAppendingPathExtension:@"savedSearch"];
	
	NSMutableDictionary *attr = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithBool:TRUE] forKey:NSFileExtensionHidden];
	
    [[NSFileManager defaultManager] createFileAtPath:filename
                                            contents:(NSData *)sf
                                          attributes:attr]; 
	
	return filename;
}

+ (NSString *)smartFolderFilenameForTagSet:(NNTagSet *)tagSet
{
	// TODO
	
	return [PASmartFolder smartFolderFilenameForTag:[[tagSet tags] objectAtIndex:0]];
}

+ (void)removeSmartFolderForTag:(NNTag *)tag
{
	NSString *filename = NSTemporaryDirectory();
	filename = [filename stringByAppendingPathComponent:[tag name]];
	filename = [filename stringByAppendingPathExtension:@"savedSearch"];
	
	[[NSFileManager defaultManager] removeFileAtPath:filename handler:nil];
}

@end
