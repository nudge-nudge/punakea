// Copyright (c) 2006-2011 nudge:nudge (Johannes Hoffart & Daniel Bär)
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

#import "HotkeyDelegateCategory.h";


@implementation Core (HotkeyDelegateCategory)

- (void)registerHotkeyForTagger
{
	NSInteger keyCode = [[NSUserDefaults standardUserDefaults] integerForKey:@"General.Hotkey.Tagger.KeyCode"];
	NSUInteger modifiers = [[NSUserDefaults standardUserDefaults] integerForKey:@"General.Hotkey.Tagger.Modifiers"];
	
	// First, unregister hotkey if it's already set up
	if (taggerHotkey)
	{
		[[PTHotKeyCenter sharedCenter] unregisterHotKey:taggerHotkey];
		[self setTaggerHotkey:nil];
	}
	
	// Eventually register new hotkey
	if (keyCode > -1)
	{		
		PTKeyCombo *keyCombo = [PTKeyCombo keyComboWithKeyCode:keyCode
													 modifiers:[[[[SRRecorderControl alloc] init] autorelease] cocoaToCarbonFlags:modifiers]];
		
		taggerHotkey = [[PTHotKey alloc] initWithIdentifier:@"TaggerHotkey"
												   keyCombo:keyCombo];
		
		[taggerHotkey setTarget:self];
		[taggerHotkey setAction:@selector(hitTaggerHotkey:)];
		
		[[PTHotKeyCenter sharedCenter] registerHotKey:taggerHotkey];
	}
}

- (void)hitTaggerHotkey:(PTHotKey *)hotKey
{
	NSString *scriptPath = [[NSBundle mainBundle] pathForResource:@"CurrentSelection" ofType:@"scpt"];
	NSURL *scriptURL = [NSURL fileURLWithPath:scriptPath];	
	
	NSAppleScript *script = [[[NSAppleScript alloc] initWithContentsOfURL:scriptURL error:nil] autorelease];
	
	NSMutableDictionary *err = [NSMutableDictionary dictionary];
	NSAppleEventDescriptor *descriptor = [script executeAndReturnError:&err];
	
	[self showTaggerActivatingLastActiveApp:YES];
	TaggerController *tagger = [self taggerController];
	
	/* Note: AppleScript arrays are one-based! (OMFG)
	   We're using the following structure of the return value:
	   { 1: Files as array,
	     2: One URL as array, first argument is location, second is title }
	*/	
		
	// Handle files	
	NSAppleEventDescriptor *filesDescriptor = [descriptor descriptorAtIndex:1];
	
	for (NSInteger i = 1; i <= [filesDescriptor numberOfItems]; i++)
	{
		NSString *location = [[filesDescriptor descriptorAtIndex:i] stringValue];
		
		[tagger addTaggableObject:[NNFile fileWithPath:location]];
	}
	
	// Handle URL
	NSAppleEventDescriptor *urlDescriptor = [descriptor descriptorAtIndex:2];
		
	if ([urlDescriptor numberOfItems] == 2)
	{
		NSString *location = [[urlDescriptor descriptorAtIndex:1] stringValue];
		NSString *title = [[urlDescriptor descriptorAtIndex:2] stringValue];
		
		// Check on a valid title - FF3 is buggy and returns only an empty string
		if ([title isEqualToString:@""])
			title = location;
		
		// Convert URL to webloc file		
		NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
		
		[pasteboard declareTypes:[NSArray arrayWithObject:NSURLPboardType]
						   owner:nil];			
		
		[pasteboard setString:location
					  forType:@"public.url"];
		[pasteboard setString:title
					  forType:@"public.url-name"];

		NSArray *files = [[PADropManager sharedInstance] handleDrop:pasteboard];
		
		[tagger addTaggableObjects:files];	
	}		
}

- (PTHotKey *)taggerHotkey
{
	return taggerHotkey;
}

- (void)setTaggerHotkey:(PTHotKey *)newHotkey
{
	[taggerHotkey release];
	taggerHotkey = [newHotkey retain];
}

@end