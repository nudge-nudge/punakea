//
//  PreferenceController.m
//  punakea
//
//  Created by Johannes Hoffart on 29.08.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PreferenceController.h"

@interface PreferenceController (PrivateAPI)

- (void)startOnLoginHasChanged;

@end

@implementation PreferenceController

#pragma mark init+dealloc
- (id)init
{
	if (self = [super initWithWindowNibName:@"Preferences"])
	{
		userDefaultsController = [NSUserDefaultsController sharedUserDefaultsController];
	}
	return self;
}

- (void)awakeFromNib
{
	[self bind:@"startOnLogin"
	  toObject:userDefaultsController
   withKeyPath:@"values.General.StartOnLogin"
	   options:nil];
	
	[userDefaultsController addObserver:self
							 forKeyPath:@"values.General.StartOnLogin"
								options:NULL
								context:NULL];
}

#pragma mark observing
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"values.General.StartOnLogin"])
	{
		[self startOnLoginHasChanged];
	}
}

#pragma mark event handling
- (void)startOnLoginHasChanged
{
	NSString *path = [[NSBundle mainBundle] bundlePath];
	
	OSStatus	status;
	CFIndex 	itemCount;
	CFIndex 	itemIndex;
	Boolean		found;
	
	CFArrayRef loginItems = NULL; 
	CFURLRef url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)path, kCFURLPOSIXPathStyle, true); 
	status = LIAECopyLoginItems(&loginItems); 
	
	if (status == noErr) {
		itemCount = CFArrayGetCount(loginItems);
		itemIndex = 0;
		found = false;
		NSDictionary *dic;
		
		while ((itemIndex < itemCount) && ! found) {
			dic = CFArrayGetValueAtIndex(loginItems,itemIndex);
			NSURL *dicUrl = [dic valueForKey:@"URL"];
			
			if ([dicUrl isEqualTo:url])
				found = true;
			else
				itemIndex++;
		}
		
		if (found && !startOnLogin) 
			LIAERemove(itemIndex); 
		CFRelease(loginItems); 
    }

	if (startOnLogin) 
		LIAEAddURLAtEnd(url, false); 
	CFRelease(url);
}

@end
