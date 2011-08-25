// Copyright (c) 2006-2011 nudge:nudge (Johannes Hoffart & Daniel Bär). All rights reserved.
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

#import "PASmartFolder.h"


@implementation PASmartFolder

+ (NSString *)smartFolderFilenameForTag:(NNTag *)tag
{
	NSMutableDictionary *sf = [NSMutableDictionary dictionary];
	[sf setObject:[NSNumber numberWithInteger:1] forKey:@"CompatibleVersion"];
	
	NSString *rawQuery = [NSString stringWithFormat:@"(true) && (((%@)))",[tag query]];
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
	[criteria addObject:@"kMDItemOMUserTags"];
	[criteria addObject:[NSNumber numberWithInteger:120]];
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
