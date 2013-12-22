//
//  OpenMetaPrefs.h
//  adobeFix
//
//  Created by Tom Andersen on 24/04/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface OpenMetaPrefs : NSObject {

}
// prefs support - this allows a common set of recently entered tags to be kept:
// recently entered tags support:
+ (NSArray*)recentTags;		// an array of NSStrings, sorted by most recently added at the top. Case preserved.

// this call is how you maintain the list of recent tags. When a user edits a list of tags on a doc, pass in the originals as 'old' and the entire set of changed ones as new. 
+ (void)updatePrefsRecentTags:(NSArray*)oldTags newTags:(NSArray*)newTags;

// To be really sure that the prefs loaded correctly for recentTags, you could call this, but calling it at each keystroke as someone types will likely get slow. 
// note that it is automatically called every few seconds when you call recentTags, so you likely don't need to call this.
+ (void)synchPrefs;	

// for app store, etc - you can set the prefs to use your own app only.. DONT call with .plist on the prefs file name..
+(void)setPrefsFile:(NSString*)prefsFileToUse;

@end
