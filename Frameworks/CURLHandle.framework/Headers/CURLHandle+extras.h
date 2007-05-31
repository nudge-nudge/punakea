//
//  CURLHandle+extras.h
//  CURLHandleTester
//
//  Created by Dan Wood <dwood@karelia.com> on Mon Oct 01 2001.
//  This is in the public domain, but please report any improvements back to the author.
//

#import "CURLHandle.h"


@interface CURLHandle ( extras )

/*" Miscellaneous functions "*/

- (void) setProgressIndicator:(id)inProgressIndicator;

/*" Set options for the transfer "*/

- (void) setConnectionTimeout:(long) inSeconds;
- (void) setCookieFile:(NSString *)inFilePath;
- (void) setRequestCookies:(NSDictionary *)inDict;
- (void) setFailsOnError:(BOOL)inFlag;
- (void) setFollowsRedirects:(BOOL)inFlag;
- (void) setPostString:(NSString *)inPostString;
- (void) setPostDictionary:(NSDictionary *)inDictionary;
- (void) setPostDictionary:(NSDictionary *)inDictionary encoding:(NSStringEncoding) inEncoding;
- (void) setProxy:(NSString *)inProxy port:(int)inPort;
- (void) setReferer:(NSString *)inReferer;
- (void) setUserAgent:(NSString *)inUserAgent;
- (void) setUserName:(NSString*)inUserName password:(NSString *)inPassword;
- (void) setNoBody:(BOOL)inNoBody;
- (void) setRange:(NSString *)inRange;
- (void) setIfModSince:(NSDate *)inModDate;

/*" Get information about the transfer "*/

- (double)downloadContentLength;
- (double)downloadSize;
- (double)downloadSpeed;
- (double)nameLookupTime;
- (double)pretransferTime;
- (double)totalTime;
- (double)uploadContentLength;
- (double)uploadSize;
- (double)uploadSpeed;
- (long)fileTime;
- (long)headerSize;
- (long)httpCode;
- (long)requestSize;

@end
