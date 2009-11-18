//
//  AppleScriptDelegateCategory.m
//  punakea
//
//  Created by Daniel on 14.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AppleScriptDelegateCategory.h"


@implementation Core (AppleScriptDelegateCategory)

- (BOOL)application:(NSApplication *)sender 
 delegateHandlesKey:(NSString *)key
{
    if ([key isEqual:@"selection"]) {
        return YES;
    } else {
        return NO;
    }
}

/**
 Get the currently selected files
 @return List of file paths
 */
- (NSArray *)selection
{
	NSMutableArray *results = [NSMutableArray array];
	
	if ([self appHasBrowser]) 
	{
		PABrowserViewMainController *mainController = [[browserController browserViewController] mainController];
		
		if ([mainController isKindOfClass:[PAResultsViewController class]])
		{
			PAResultsOutlineView *ov = [(PAResultsViewController*)mainController outlineView];
			
			for (NSInteger i = 0; i < [[ov selectedItems] count]; i++)
			{
				NNFile *file = [[ov selectedItems] objectAtIndex:i];
				
				[results addObject:[file path]];
			}
		}
	}
	
	return results;
}

@end
