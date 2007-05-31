/*

BSD License

Copyright (c) 2003, Brent Simmons
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

*	Redistributions of source code must retain the above copyright notice,
	this list of conditions and the following disclaimer.
*	Redistributions in binary form must reproduce the above copyright notice,
	this list of conditions and the following disclaimer in the documentation
	and/or other materials provided with the distribution.
*	Neither the name of ranchero.com or Brent Simmons nor the names of its
	contributors may be used to endorse or promote products derived
	from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


*/

/*
	XMLRPCRequest.m

	Created by Brent Simmons on Sun Feb 16 2003.
	Copyright (c) 2003 Ranchero Software. All rights reserved.
*/


#import "XMLRPCRequest.h"


@implementation XMLRPCRequest


- (void) dealloc {
	
	[methodName release];
	
	[parameters release];
	} /*dealloc*/
	
	
- (void) setMethodName: (NSString *) s {
	
	if (methodName != nil)
		[methodName autorelease];
	
	if (s == nil)
		methodName = nil;
	else
		methodName = [s retain];
	} /*setMethodName*/
	

- (NSString *) methodName {
	
	return (methodName);
	} /*methodName*/
	

- (void) setParameters: (NSArray *) params {
		
	if (parameters != nil)
		[parameters autorelease];
	
	if (params == nil)
		parameters = nil;
	else
		parameters = [params retain];
	} /*setParameters*/
	

- (NSArray *) parameters {
	
	return (parameters);
	} /*parameters*/
	

/*XML request creation*/

- (void) appendMethodName: (NSMutableString *) s {
	
	[s appendString: @"<methodCall>\n"];
	
	[s appendString: @"\t<methodName>"];
	
	[s appendString: methodName];
	
	[s appendString: @"</methodName>\n"];
	} /*appendMethodName*/
	
	
- (void) endMethodCall: (NSMutableString *) s {
	
	[s appendString: @"\t</methodCall>"];
	} /*endMethodCall*/
	

- (NSString *) replaceAll: (NSString *) searchFor with: (NSString *) replaceWith inString: (NSString *) s {
	
	NSArray *stringComponents = [s componentsSeparatedByString: searchFor];

	return [stringComponents componentsJoinedByString: replaceWith];	
	} /*replaceAll*/
	
	
- (NSString *) escapeValue: (NSString *) s {
	
	s = [self replaceAll: @"&" with: @"&amp;" inString: s];
	
	s = [self replaceAll: @"<" with: @"&lt;" inString: s];
	
	return (s);
	} /*escapeValue*/
	
	
- (void) appendTaggedValue: (NSString *) tagName value: (NSString *) val toString: (NSMutableString *) s {
	
	[s appendString: @"\t\t\t<value><"];
	
	[s appendString: tagName];
	
	[s appendString: @">"];
	
	[s appendString: [self escapeValue: val]];
	
	[s appendString: @"</"];
	
	[s appendString: tagName];
	
	[s appendString: @"></value>\n"];
	} /*appendTaggedValue*/
	
	
- (void) serializeNumber: (NSNumber *) num toString: (NSMutableString *) s {
	
	NSString *val = [num stringValue];
	
	[self appendTaggedValue: @"int" value: val toString: s];
	} /*serializeNumber*/
	
	
- (void) serializeString: (NSString *) stringValue toString: (NSMutableString *) s {
	
	[self appendTaggedValue: @"string" value: stringValue toString: s];
	} /*serializeString*/
	

- (void) serializeDate: (NSDate *) date toString: (NSMutableString *) s {
	
	/*Sample date string: 19980717T14:08:55*/
	
	NSString *dateString = [date descriptionWithCalendarFormat: @"%y%m%dT%H:%M:%S" timeZone: nil locale: nil];

	[self appendTaggedValue: @"dateTime.iso8601" value: dateString toString: s];
	} /*serializeDate*/


static char base64EncodingTable [64] = {

	'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P',
	
	'Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f',
	
	'g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v',
	
	'w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/'
	};
	

- (NSString *) base64StringWithData: (NSData *) d lineLength: (int) lineLength {

	/*
	Return an autoreleased string that's a base64-encoded version
	of self.
	
	This code was adapted from code written by Dave Winer and posted here:
	http://www.scripting.com/midas/base64/source.html
	
	This should probably be in an NSData category. Feel free.
	*/
	
	/*
	[Dave's original comments...]
	encode the handle. some funny stuff about linelength -- it only makes
	sense to make it a multiple of 4. if it's not a multiple of 4, we make it
	so (by only checking it every 4 characters. 
 
	further, if it's 0, we don't add any line breaks at all.
	*/
 
	unsigned long ixtext;
	unsigned long lentext;
	long ctremaining;
	unsigned char inbuf [3], outbuf [4];
	short i;
	short charsonline = 0, ctcopy;
	const unsigned char *rawData;
	NSMutableString *s;
    
	lentext = [d length];

	if (lentext < 1)
		return (@"");
		
 	s = [NSMutableString stringWithCapacity: lentext];
 	
 	rawData = [d bytes];

	ixtext = 0; 
 	
	while (true) {
 
		ctremaining = lentext - ixtext;
	
		if (ctremaining <= 0)
			break;
				
		for (i = 0; i < 3; i++) { 
		
			unsigned long ix = ixtext + i;
		
			if (ix < lentext)
				inbuf [i] = rawData [ix];
			else
				inbuf [i] = 0;
			} /*for*/
		
		outbuf [0] = (inbuf [0] & 0xFC) >> 2;
    
		outbuf [1] = ((inbuf [0] & 0x03) << 4) | ((inbuf [1] & 0xF0) >> 4);
    
		outbuf [2] = ((inbuf [1] & 0x0F) << 2) | ((inbuf [2] & 0xC0) >> 6);
    	
		outbuf [3] = inbuf [2] & 0x3F;
	
		ctcopy = 4;
	
		switch (ctremaining) {
		
			case 1: 
				ctcopy = 2; 
			
				break;
		
			case 2: 
				ctcopy = 3; 
			
				break;
			} /*switch*/
 
		for (i = 0; i < ctcopy; i++) {
		
			NSString *charString = [NSString stringWithFormat: @"%c", base64EncodingTable [outbuf [i]]];
			
			[s appendString: charString];
			} /*for*/

		for (i = ctcopy; i < 4; i++)
			[s appendString: @"="];
		
		ixtext += 3;
	
		charsonline += 4;
	
		if (lineLength > 0) { /*DW 4/8/97 -- 0 means no line breaks*/
	
			if (charsonline >= lineLength) {
			
				charsonline = 0;
				
				[s appendString: @"\n"];
				}
			}
		} /*while*/
 
	return [[s copy] autorelease];
	} /*base64StringWithData*/


- (void) serializeData: (NSData *) d toString: (NSMutableString *) s {
	
	/*Convert to base64 first.*/
	
	NSString *base64String = [self base64StringWithData: d lineLength: 0];
	
	[self appendTaggedValue: @"base64" value: base64String toString: s];
	} /*serializeData*/
	
	
- (void) serializeBoolean: (CFBooleanRef) fl toString: (NSMutableString *) s {
	
	if (fl == kCFBooleanTrue)
		[self appendTaggedValue: @"boolean" value: @"1" toString: s];
	else
		[self appendTaggedValue: @"boolean" value: @"0" toString: s];
	} /*serializeString*/


- (void) serializeDictionary: (NSDictionary *) d toString: (NSMutableString *) s {
	
	NSEnumerator *keyEnumerator = [d keyEnumerator];
	NSString *oneKey;
	
	[s appendString: @"\t\t\t<value>\n"];
	
	[s appendString: @"\t\t\t<struct>\n"];
	
	while (oneKey = [keyEnumerator nextObject]) {
		
		id oneItem = [d objectForKey: oneKey];
		
		[s appendString: @"\t\t\t<member>\n"];
		
		[s appendString: @"\t\t\t<name>"];
		
		[s appendString: oneKey];
		
		[s appendString: @"</name>\n"];
		
		[self serializeObject: oneItem toString: s];

		[s appendString: @"\t\t\t</member>\n"];
		} /*while*/
	
	[s appendString: @"\t\t\t</struct>\n"];
	
	[s appendString: @"\t\t\t</value>\n"];
	} /*serializeDictionary*/


- (void) serializeArray: (NSArray *) anArray toString: (NSMutableString *) s {
	
	NSEnumerator *enumerator = [anArray objectEnumerator];
	id oneItem;
	
	[s appendString: @"\t\t\t<value>\n"];
	
	[s appendString: @"\t\t\t<array>\n"];

	[s appendString: @"\t\t\t<data>\n"];
	
	while (oneItem = [enumerator nextObject])
		[self serializeObject: oneItem toString: s];
	
	[s appendString: @"\t\t\t</data>\n"];

	[s appendString: @"\t\t\t</array>\n"];
	
	[s appendString: @"\t\t\t</value>\n"];
	} /*serializeArray*/


- (void) serializeObject: (id) obj toString: (NSMutableString *) s {
	
	if (((CFBooleanRef) obj == kCFBooleanTrue) || ((CFBooleanRef) obj == kCFBooleanFalse))
		[self serializeBoolean: (CFBooleanRef) obj toString: s];

	else if ([obj isKindOfClass: [NSNumber class]])
		[self serializeNumber: obj toString: s];

	else if ([obj isKindOfClass: [NSDate class]])
		[self serializeDate: obj toString: s];

	else if ([obj isKindOfClass: [NSData class]])
		[self serializeData: obj toString: s];
		
	else if ([obj isKindOfClass: [NSString class]])
		[self serializeString: obj toString: s];

	else if ([obj isKindOfClass: [NSArray class]])
		[self serializeArray: obj toString: s];

	else if ([obj isKindOfClass: [NSDictionary class]])
		[self serializeDictionary: obj toString: s];
	} /*serializeObject*/
	
	
- (void) serializeParams: (NSMutableString *) s {
	
	NSEnumerator *enumerator;
	id oneParam;
	
	[s appendString: @"\t<params>\n"];
	
	enumerator = [parameters objectEnumerator];
	
	while (oneParam = [enumerator nextObject]) {
		
		[s appendString: @"\t\t<param>\n"];
		
		[self serializeObject: oneParam toString: s];
		
		[s appendString: @"\t\t\t</param>\n"];
		} /*while*/
	
	[s appendString: @"\t\t</params>\n"];	
	} /*serializeParams*/
	
	
- (NSString *) requestText {
	
	/*
	PBS 02/16/03: after setting everything that needs to be set,
	call this to get the XML-RPC request text.
	*/
	
	NSMutableString *s = [NSMutableString stringWithCapacity: 256]; /*whatever*/
	
	[s appendString: @"<?xml version=\"1.0\"?>\n"];
	
	[self appendMethodName: s];
	
	[self serializeParams: s];
	
	[self endMethodCall: s];
	
	return (s);
	} /*requestText*/


@end
