// Copyright (c) 2006-2012 nudge:nudge (Johannes Hoffart & Daniel Bär). All rights reserved.
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

#import "PADropManager.h"

#import "PATagButton.h"

@interface PADropManager (PrivateAPI)

- (void)loadAllPlugins;
- (NSMutableArray *)allBundles;
- (BOOL)plugInClassIsValid:(Class)plugInClass;

@end

@implementation PADropManager

//this is where the sharedInstance is held
static PADropManager *sharedInstance = nil;
NSString *ext = @"punakeaDropHandler";
NSString *appSupportSubpath = @"Application Support/Punakea/PlugIns";

#pragma mark init
//constructor - only called by sharedInstance
- (id)sharedInstanceInit {
	if (self = [super init])
	{
		// load all drophandlers
		dropHandlers = [[NSMutableArray alloc] init];
		[self loadAllPlugins];
	}
	return self;
}

- (void)dealloc
{
	[dropHandlers release];
	[super dealloc];
}

- (void)registerDropHandler:(PADropHandler*)handler
{
	if ([[self handledPboardTypes] containsObject:[handler pboardType]])
	{
		lcl_log(lcl_cglobal, lcl_vWarning, @"%@ not added, pboardType already registered by another dropHandler", handler);
	}
	else
	{
		lcl_log(lcl_cglobal, lcl_vInfo, @"Added drophandler: %@", handler);
		[dropHandlers addObject:handler];
	}
}
	
- (void)removeDropHandler:(PADropHandler*)handler
{
	[dropHandlers removeObject:handler];
}

- (BOOL)acceptsSender:(id)sender
{
	// at the moment only PATagButtons are ignored
	if([sender isMemberOfClass:[PATagButton class]])
		return NO;
	else
		return YES;
}

- (NSArray*)handledPboardTypes
{
	NSMutableArray *handledTypes = [NSMutableArray array];
	
	NSEnumerator *e = [dropHandlers objectEnumerator];
	PADropHandler *dropHandler;
	
	while (dropHandler = [e nextObject])
	{
		[handledTypes addObject:[dropHandler pboardType]];
	}
		
	return handledTypes;
}

- (NSArray*)handleDrop:(NSPasteboard*)pasteboard
{
	NSArray *result = nil;
	
	NSEnumerator *e = [dropHandlers objectEnumerator];
	PADropHandler *dropHandler;
	
	// all dropHandlers are queried if they handle the needed pboardType
	while (dropHandler = [e nextObject])
	{
		if ([dropHandler willHandleDrop:pasteboard])
		{
			result = [dropHandler handleDrop:pasteboard];
			break;
		}
	}

	return result;
}

- (NSDragOperation)performedDragOperation:(NSPasteboard*)pasteboard
{
	NSDragOperation op = NSDragOperationNone;
	
	NSEnumerator *e = [dropHandlers objectEnumerator];
	PADropHandler *dropHandler;
	
	while (dropHandler = [e nextObject])
	{
		if ([dropHandler willHandleDrop:pasteboard])
			op = [dropHandler performedDragOperation:pasteboard];
	}
	
	// If self is in alternate state, toggle performed drag operation
	if([self alternateState])
	{
		if(op == NSDragOperationMove)
			op = NSDragOperationLink;
		else if(op == NSDragOperationLink)
			op = NSDragOperationMove;
	}
	
	return op;
}

#pragma mark plugin stuff
- (void)loadAllPlugins
{
    NSMutableArray *bundlePaths;
    NSEnumerator *pathEnum;
    NSString *currPath;
    NSBundle *currBundle;
    Class currPrincipalClass;
    id currInstance;
    
    bundlePaths = [NSMutableArray array];
   
    [bundlePaths addObjectsFromArray:[self allBundles]];
    
    pathEnum = [bundlePaths objectEnumerator];
    while(currPath = [pathEnum nextObject])
    {
        currBundle = [NSBundle bundleWithPath:currPath];
        if(currBundle)
        {
            currPrincipalClass = [currBundle principalClass];
            if(currPrincipalClass &&
               [self plugInClassIsValid:currPrincipalClass])  // Validation
            {
                currInstance = [[currPrincipalClass alloc] init];
                if(currInstance)
                {
                    [self registerDropHandler:[currInstance autorelease]];
                }
            }
        }
    }
}

- (NSMutableArray *)allBundles
{
    NSArray			*librarySearchPaths;
    
    NSMutableArray	*bundleSearchPaths = [NSMutableArray array];
    NSMutableArray	*allBundles = [NSMutableArray array];
    
    librarySearchPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSAllDomainsMask - NSSystemDomainMask, YES);
    
    for (NSString *currPath in librarySearchPaths)
    {
        [bundleSearchPaths addObject:
            [currPath stringByAppendingPathComponent:appSupportSubpath]];
    }
    [bundleSearchPaths addObject:[[NSBundle mainBundle] builtInPlugInsPath]];
    
	for (NSString *currPath in bundleSearchPaths)
    {
        NSDirectoryEnumerator *bundleEnum;
        NSString *currBundlePath;
        bundleEnum = [[NSFileManager defaultManager] enumeratorAtPath:currPath];
        if(bundleEnum)
        {
            while(currBundlePath = [bundleEnum nextObject])
            {
                if([[currBundlePath pathExtension] isEqualToString:ext])
                {
					[allBundles addObject:[currPath stringByAppendingPathComponent:currBundlePath]];
                }
            }
        }
    }
    
    return allBundles;
}

- (BOOL)plugInClassIsValid:(Class)plugInClass
{
    if([plugInClass isSubclassOfClass:[PADropHandler class]])
    {
        return YES;
    }
    
    return NO;
}


#pragma mark singleton stuff
+ (PADropManager*)sharedInstance {
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


#pragma mark Accessors
- (BOOL)alternateState
{
	return alternateState;
}

- (void)setAlternateState:(BOOL)flag
{
	alternateState = flag;
}

@end
