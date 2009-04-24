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
	[sf setObject:[NSNumber numberWithInt:1] forKey:@"CompatibleVersion"];
	
	NSString *rawQuery = [NSString stringWithFormat:@"(%@)",[tag query]];
	[sf setObject:rawQuery forKey:@"RawQuery"];
	
	NSMutableDictionary *rawQueryDict = [NSMutableDictionary dictionary];
	[rawQueryDict setObject:[NSNumber numberWithBool:YES] forKey:@"FinderFilesOnly"];
	[rawQueryDict setObject:rawQuery forKey:@"RawQuery"];
	[rawQueryDict setObject:[NSArray arrayWithObject:@"kMDQueryScopeComputer"] forKey:@"SearchScopes"];
	[rawQueryDict setObject:[NSNumber numberWithBool:YES] forKey:@"UserFilesOnly"];
	
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
	[criteria addObject:@"kMDItemFinderComment"];
	[criteria addObject:[NSNumber numberWithInt:100]];
	[criteria addObject:[NSNumber numberWithInt:104]];
	[criteriaSlice setObject:criteria forKey:@"criteria"];
	
	NSString *tagPrefix = [[NNTagStoreManager defaultManager] tagPrefix];
	NSMutableArray *displayValues = [NSMutableArray array];
	[displayValues addObject:@"Spotlight-Kommentar"];
	[displayValues addObject:@"contains"];
	[displayValues addObject:[NSString stringWithFormat:@"%@%@",tagPrefix,[tag name]]];
	[criteriaSlice setObject:displayValues forKey:@"displayValues"];
	
	[criteriaSlice setObject:[NSNumber numberWithInt:0] forKey:@"rowType"];
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
