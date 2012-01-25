// Copyright (c) 2006-2012 nudge:nudge (Johannes Hoffart & Daniel Bär)
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
