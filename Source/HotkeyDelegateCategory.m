#import "HotkeyDelegateCategory.h";


@implementation Core (HotkeyDelegateCategory)

- (void)registerHotkeyForTagger
{
	int keyCode = [[NSUserDefaults standardUserDefaults] integerForKey:@"General.Hotkey.Tagger.KeyCode"];
	unsigned int modifiers = [[NSUserDefaults standardUserDefaults] integerForKey:@"General.Hotkey.Tagger.Modifiers"];
	
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
													 modifiers:[[[SRRecorderControl alloc] init] cocoaToCarbonFlags:modifiers]];
		
		taggerHotkey = [[PTHotKey alloc] initWithIdentifier:@"TaggerHotkey"
												   keyCombo:keyCombo];
		
		[taggerHotkey setTarget:self];
		[taggerHotkey setAction:@selector(hitTaggerHotkey:)];
		
		[[PTHotKeyCenter sharedCenter] registerHotKey:taggerHotkey];
	}
}

- (void)hitTaggerHotkey:(PTHotKey *)hotKey
{
	NSLog(@"Hit Me, Baby!");
	
	// Get selected items from Finder
	NSString *s = @"tell application \"Finder\"\n";	
	s = [s stringByAppendingString:@"set selectedItem to (posix path of (the selection as alias))\n"];	
	s = [s stringByAppendingString:@"end tell"];
	
	NSAppleScript *folderActionScript = [[NSAppleScript alloc] initWithSource:s];
	NSAppleEventDescriptor *descriptor = [folderActionScript executeAndReturnError:nil];
	
	NSLog(@"descriptor: %@", [descriptor stringValue]);	
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