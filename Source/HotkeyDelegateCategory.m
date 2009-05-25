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
	
	for (int i = 1; i <= [filesDescriptor numberOfItems]; i++)
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