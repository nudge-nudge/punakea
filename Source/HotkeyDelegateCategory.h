#import <Cocoa/Cocoa.h>
#import "Core.h";
#import "PTHotKeyCenter.h";


@interface Core (HotkeyDelegateCategory)

- (void)registerHotkeyForTagger;

- (PTHotKey *)taggerHotkey;
- (void)setTaggerHotkey:(PTHotKey *)newHotkey;

@end