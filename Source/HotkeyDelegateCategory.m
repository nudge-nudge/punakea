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
	NSLog(@"Hit Me, Baby!");
	
	// Get selected items from Finder	
	NSString *scriptPath = [[NSBundle mainBundle] pathForResource:@"CurrentSelection" ofType:@"scpt"];
	NSURL *scriptURL = [NSURL fileURLWithPath:scriptPath];	
	
	NSAppleScript *script = [[NSAppleScript alloc] initWithContentsOfURL:scriptURL error:nil];
	NSAppleEventDescriptor *descriptor = [script executeAndReturnError:nil];
	
	NSMutableArray *items = [NSMutableArray array];
	
	// Note: AppleScript arrays are one-based!
	for (int i = 1; i <= [descriptor numberOfItems]; i++)
	{
		NSLog(@"%@", [[descriptor descriptorAtIndex:i] stringValue]);	
		[items addObject:[[descriptor descriptorAtIndex:i] stringValue]];
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