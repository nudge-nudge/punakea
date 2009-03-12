#import <Cocoa/Cocoa.h>
#import "Core.h";
#import "PTHotKeyCenter.h";

@class SRRecorderControl;


@interface Core (HotkeyDelegateCategory)

- (void)registerHotkeyForTagger;

- (PTHotKey *)taggerHotkey;
- (void)setTaggerHotkey:(PTHotKey *)newHotkey;

@end