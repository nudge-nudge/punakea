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
	[sf setObject:[NSNumber numberWithInt:0] forKey:@"CompatibleVersion"];
	
	NSString *rawQuery = [tag queryInSpotlightSyntax];	
	[sf setObject:rawQuery forKey:@"RawQuery"];	
	
	// Search criteria are needed for editing the folder later on in Finder
	NSMutableDictionary *criteria = [NSMutableDictionary dictionary];
	
	NSString *currentFolderPath = @"~";
	NSMutableArray *currentFolderPathArray = [NSMutableArray arrayWithObject:[currentFolderPath stringByExpandingTildeInPath]];
	[criteria setObject:currentFolderPathArray forKey:@"CurrentFolderPath"];
	
	[criteria setObject:[NSNumber numberWithLongLong:1396926573] forKey:@"FXScope"];
	
	NSMutableArray *scopeArrayOfPaths = [NSMutableArray arrayWithObject:@"kMDQueryScopeHome"];
	[criteria setObject:scopeArrayOfPaths forKey:@"FXScopeArrayOfPaths"];
	
	NSMutableDictionary *criteriaSlice = [NSMutableDictionary dictionary];
	[criteriaSlice setObject:@"kMDItemFinderComment" forKey:@"FXAttribute"];
	[criteriaSlice setObject:@"Othr" forKey:@"FXSliceKind"];
	[criteriaSlice setObject:@"S:**" forKey:@"Operator"];
	
	NSString *value = @"@";
	[criteriaSlice setObject:[value stringByAppendingString:[[tag name] stringByAppendingString:@";"]] forKey:@"Value"];
	
	NSMutableArray *criteriaSlices = [NSMutableArray arrayWithObject:criteriaSlice];
	[criteria setObject:criteriaSlices forKey:@"FXCriteriaSlices"];
	
	[sf setObject:criteria forKey:@"SearchCriteria"];
	
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

+ (void)removeSmartFolderForTag:(NNTag *)tag
{
	NSString *filename = NSTemporaryDirectory();
	filename = [filename stringByAppendingPathComponent:[tag name]];
	filename = [filename stringByAppendingPathExtension:@"savedSearch"];
	
	[[NSFileManager defaultManager] removeFileAtPath:filename handler:nil];
}

@end
