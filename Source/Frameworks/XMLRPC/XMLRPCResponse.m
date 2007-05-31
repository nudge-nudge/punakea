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
	XMLRPCResponse.m

	Created by Brent Simmons on Thu Feb 13 2003.
	Copyright (c) 2003 Ranchero Software. All rights reserved.
*/


#import "XMLRPCResponse.h"


@implementation XMLRPCResponse


- (id) initWithData: (NSData *) d {
	
	faultCode = 0;
	
	isFault = NO;

	if (d == nil) {
	
		NSException *exception =
			[NSException exceptionWithName: @"XML-RPC Response Parsing Failed"
			reason: @"No data was available for parsing." userInfo: nil];
			
		[exception raise];
		} /*if*/

	responseText = [[NSString alloc] initWithData: d encoding: NSISOLatin1StringEncoding];	

	mainTree = CFXMLTreeCreateFromData (kCFAllocatorDefault,
		(CFDataRef) d, NULL,  kCFXMLParserSkipWhitespace, kCFXMLNodeCurrentVersion);

	if (mainTree == nil) {
		
		/*It seems crazy, but it works. If at first you don't succeed, try Unicode.
		There's probably a better way.*/
		
		NSData *dataUnicodeCopy;
		
		responseText = [[[NSString alloc] initWithData: d encoding: NSISOLatin1StringEncoding] autorelease];
	
		dataUnicodeCopy = [responseText dataUsingEncoding: NSUnicodeStringEncoding];

		mainTree = CFXMLTreeCreateFromData (kCFAllocatorDefault,
			(CFDataRef) dataUnicodeCopy, NULL,  kCFXMLParserSkipWhitespace, kCFXMLNodeCurrentVersion);

		if (mainTree == nil) {
			
			/*Last-ditch attempt: be forgiving with ampersands.*/
			
			NSArray *stringComponents;

			stringComponents = [responseText componentsSeparatedByString: @"&amp;"];
			responseText = [stringComponents componentsJoinedByString: @"&"];

			stringComponents = [responseText componentsSeparatedByString: @"&"];
			responseText = [stringComponents componentsJoinedByString: @"&amp;"];
	
			dataUnicodeCopy = [responseText dataUsingEncoding: NSUnicodeStringEncoding];

			mainTree = CFXMLTreeCreateFromData (kCFAllocatorDefault,
				(CFDataRef) dataUnicodeCopy, NULL,  kCFXMLParserSkipWhitespace, kCFXMLNodeCurrentVersion);
				
			if (mainTree == nil) {

				/*If there was a problem parsing the XML,
				raise an exception.*/
			
				NSException *exception =
					[NSException exceptionWithName: @"XML-RPC Response Parsing Failed"
					reason: @"The XML parser could not parse the data." userInfo: nil];
				
				[exception raise];
				} /*if*/
			} /*if*/
		} /*if*/

	[self parseResponse];
	
	CFRelease (mainTree);
	
	return (self);
	} /*initWithData*/


- (void) dealloc {
	
	[faultString release];
	
	[returnedObject release];

	[responseText release];
	} /*dealloc*/
	

- (NSString *) responseText {
	
	return (responseText);
	} /*responseText*/
	
	
- (id) returnedObject {
	
	return (returnedObject);
	} /*returnedObject*/
	

- (BOOL) isFault {
	
	return (isFault);
	} /*isFault*/
	

- (NSString *) faultString {
	
	return (faultString);
	} /*faultString*/


- (int) faultCode {
	
	return (faultCode);
	} /*faultCode*/


/*Utility routines*/

- (int) getChildCount: (CFXMLTreeRef) tree {
	
	return (CFTreeGetChildCount (tree));	
	} /*getChildCount*/
	
	
- (CFXMLTreeRef) getNamedTree: (CFXMLTreeRef) currentTree name: (NSString *) name {
	
	int childCount, index;
	CFXMLNodeRef xmlNode;
	CFXMLTreeRef xmlTreeNode;
	NSString *itemName;
	
	childCount = CFTreeGetChildCount (currentTree);
	
	for (index = childCount - 1; index >= 0; index--) {
		
		xmlTreeNode = CFTreeGetChildAtIndex (currentTree, index);
		
		xmlNode = CFXMLTreeGetNode (xmlTreeNode);
		
		itemName = (NSString *) CFXMLNodeGetString (xmlNode);
		
		if ([itemName isEqualToString: name])
			return (xmlTreeNode);
		} /*for*/
	
	return (nil);
	} /*getNamedTree*/


- (NSString *) getTreeName: (CFXMLTreeRef) tree {

	CFXMLNodeRef node = nil;
	
	node = CFXMLTreeGetNode (tree);

	if (node == nil)
		return (@"");
		
	return ((NSString *) CFXMLNodeGetString (node));
	} /*getTreeName*/
	
	
- (NSString *) getElementValue: (CFXMLTreeRef) tree {
	
	CFXMLNodeRef node;
	CFXMLTreeRef itemTree;
	int childCount, ix;
	NSMutableString *valueMutable;
	NSString *name;
	
	childCount = CFTreeGetChildCount (tree);
	
	valueMutable = [NSMutableString stringWithCapacity: 256]; /*whatever*/
	
	for (ix = 0; ix < childCount; ix++) {
		
		itemTree = CFTreeGetChildAtIndex (tree, ix);
		
		node = CFXMLTreeGetNode (itemTree);
		
		name = (NSString *) CFXMLNodeGetString (node);
		
		if (name != nil) {
		
			if (CFXMLNodeGetTypeCode (node) == kCFXMLNodeTypeEntityReference) {
				
				if ([name isEqualToString: @"lt"])
					name = @"<";

				if ([name isEqualToString: @"gt"])
					name = @">";
				
				if ([name isEqualToString: @"quot"])
					name = @"\"";
				
				if ([name isEqualToString: @"amp"])
					name = @"&";				
				} /*if*/
						
			[valueMutable appendString: name];
			} /*if*/
		} /*for*/
	
	return (NSString *) [[valueMutable copy] autorelease];
	} /*getElementValue*/


- (CFXMLTreeRef) getFirstParamValueTree {
	
	CFXMLTreeRef methodResponseTree, paramsTree, paramTree, valueTree;

	valueTree = nil;
	
	methodResponseTree = [self getNamedTree: mainTree name: @"methodResponse"];
	
	if (methodResponseTree == nil)
		return (nil);
	
	paramsTree = [self getNamedTree: methodResponseTree name: @"params"];
	
	if (paramsTree == nil)
		return (nil);

	paramTree = [self getNamedTree: paramsTree name: @"param"];
	
	if (paramTree == nil)
		return (nil);

	valueTree = [self getNamedTree: paramTree name: @"value"];
	
	return (valueTree);
	} /*getFirstParamValueTree*/
	
	
- (CFXMLTreeRef) getFaultStructTree {
	
	CFXMLTreeRef methodResponseTree, faultTree, valueTree, structTree;

	methodResponseTree = [self getNamedTree: mainTree name: @"methodResponse"];
	
	if (methodResponseTree == nil)
		return (nil);
	
	faultTree = [self getNamedTree: methodResponseTree name: @"fault"];
	
	if (faultTree == nil)
		return (nil);

	valueTree = [self getNamedTree: faultTree name: @"value"];
	
	if (valueTree == nil)
		return (nil);

	structTree = [self getNamedTree: valueTree name: @"struct"];
	
	return (structTree);
	} /*getFaultStructTree*/
	
	
/*Parsing routines*/

- (void) parseResponse {
	
	CFXMLTreeRef valueTree = [self getFirstParamValueTree];
	
	if (valueTree == nil) {
	
		[self parseFault];
		
		return;
		} /*if*/
		
	returnedObject = [self parseValue: valueTree];
	
	if (returnedObject != nil)
		[returnedObject retain];
	} /*parseResponse*/


- (void) parseFault {
	
	CFXMLTreeRef faultStructTree = [self getFaultStructTree];
	NSMutableDictionary *faultDictionary;
	NSString *s;
	NSNumber *n;
	
	isFault = YES;
	
	if (faultStructTree == nil) {
		
		faultCode = -1;
		
		faultString = [[NSString alloc]
			initWithString: @"Unknown fault."];
		
		return;
		} /*if*/
	
	faultDictionary = [self parseStruct: faultStructTree];
	
	s = [faultDictionary objectForKey: @"faultString"];
	
	if (s == nil)
		s = @"Unknown fault.";
		
	faultString = [s retain];
	
	n = [faultDictionary objectForKey: @"faultCode"];
	
	if (n == nil)
		faultCode = -1;
	else
		faultCode = [n intValue];
	} /*parseFault*/


- (NSMutableArray *) parseArray: (CFXMLTreeRef) tree {
	
	NSMutableArray *anArray = [NSMutableArray arrayWithCapacity: 10];
	CFXMLTreeRef dataTree;
	int childCount, i;
	
	dataTree = [self getNamedTree: tree name: @"data"];
	
	if (dataTree == nil)
		return (nil);
	
	childCount = [self getChildCount: dataTree];
	
	for (i = 0; i < childCount; i++) {
		
		CFXMLTreeRef childTree;
		NSString *childName;
		id childValue;
		
		childTree = CFTreeGetChildAtIndex (dataTree, i);

		childName = [self getTreeName: childTree];
		
		if (![childName isEqualToString: @"value"])
			continue;
		
		childValue = [self parseValue: childTree];
		
		if (childValue != nil)
			[anArray addObject: childValue];
		} /*for*/
	
	return (anArray);
	} /*parseArray*/


- (NSMutableDictionary *) parseStruct: (CFXMLTreeRef) tree {
	
	NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity: 10];
	int childCount, i;
	
	childCount = [self getChildCount: tree];
	
	for (i = 0; i < childCount; i++) {
			
		CFXMLTreeRef memberTree;
		CFXMLTreeRef nameTree, valueTree;
		NSString *name;
		id value;

		memberTree = CFTreeGetChildAtIndex (tree, i);

		name = [self getTreeName: memberTree];
		
		if (![name isEqualToString: @"member"])
			continue;
		
		nameTree = [self getNamedTree: memberTree name: @"name"];
		
		if (nameTree == nil)
			continue;
		
		name = [self getElementValue: nameTree];
		
		valueTree = [self getNamedTree: memberTree name: @"value"];
		
		if (valueTree == nil)
			continue;
		
		value = [self parseValue: valueTree];
		
		if (value != nil)
			if (name != nil)
				if (![name isEqualToString: @""])
					[d setObject: value forKey: name];
		} /*for*/
	
	return (d);
	} /*parseStruct*/


- (NSString *) parseString: (CFXMLTreeRef) tree {
	
	return [self getElementValue: tree];
	} /*parseString*/


- (NSNumber *) parseInt: (CFXMLTreeRef) tree {
	
	NSString *s = [self getElementValue: tree];
	int n = [s intValue];
	
	return [NSNumber numberWithInt: n];	
	} /*parseInt*/


- (CFBooleanRef) parseBoolean: (CFXMLTreeRef) tree {
	
	NSString *s = [self getElementValue: tree];

	if ([s isEqualToString: @"1"])
		return (kCFBooleanTrue);
	
	return (kCFBooleanFalse);
	} /*parseBoolean*/


- (NSNumber *) parseDouble: (CFXMLTreeRef) tree {
	
	NSString *s = [self getElementValue: tree];
	double n = [s doubleValue];
	
	return [NSNumber numberWithDouble: n];	
	} /*parseDouble*/


- (NSDate *) parseDateTime: (CFXMLTreeRef) tree {
	
	NSString *dateString = [self getElementValue: tree];
	NSCalendarDate *d = [NSCalendarDate dateWithString: dateString calendarFormat: @"%y%m%dT%H:%M:%S"
		locale: nil];

	return (d);
	} /*parseDateTime*/


- (NSData *) dataWithBase64String: (NSString *) base64String {
	
	/*
	Decode a base64 string; return an NSData object (autoreleased).
	This code was adapted from code written by Dave Winer and posted here:
	http://www.scripting.com/midas/base64/source.html
	
	This should probably be in an NSData category. Feel free.
	*/
	
	unsigned long ixtext;
	unsigned long lentext;
	unsigned char ch;
	unsigned char inbuf [3], outbuf [4];
	short i, ixinbuf;
	Boolean flignore;
	Boolean flendtext = false;
	const unsigned char *tempcstring;
	NSMutableData *d;
	
	if (base64String == nil)
		return [NSData data];
		
	ixtext = 0;
	
	tempcstring = [base64String cString];
	
	lentext = [base64String length];
	
	d = [NSMutableData dataWithCapacity: lentext];
	
	ixinbuf = 0;
 
	while (true) {
	
		if (ixtext >= lentext)
			break;
		
		ch = tempcstring [ixtext++];
			
		flignore = false;
	
		if ((ch >= 'A') && (ch <= 'Z'))
			ch = ch - 'A';
	
		else if ((ch >= 'a') && (ch <= 'z'))
			ch = ch - 'a' + 26;
		
		else if ((ch >= '0') && (ch <= '9'))
			ch = ch - '0' + 52;
	
		else if (ch == '+')
			ch = 62;
		
		else if (ch == '=') /*no op -- can't ignore this one*/
			flendtext = true;
		
		else if (ch == '/')
			ch = 63;
	
		else
			flignore = true; 
	
		if (!flignore) {
	
			short ctcharsinbuf = 3;
			Boolean flbreak = false;
			 
			if (flendtext) {
			
				if (ixinbuf == 0)
					break;
				
				if ((ixinbuf == 1) || (ixinbuf == 2))
					ctcharsinbuf = 1;
				else
					ctcharsinbuf = 2;
			
				ixinbuf = 3;
			
				flbreak = true;
				}
		
			inbuf [ixinbuf++] = ch;
		
			if (ixinbuf == 4) {
			
				ixinbuf = 0;
			
				outbuf [0] = (inbuf [0] << 2) | ((inbuf [1] & 0x30) >> 4);
			
				outbuf [1] = ((inbuf [1] & 0x0F) << 4) | ((inbuf [2] & 0x3C) >> 2);
			
				outbuf [2] = ((inbuf [2] & 0x03) << 6) | (inbuf [3] & 0x3F);
	
				for (i = 0; i < ctcharsinbuf; i++)
					[d appendBytes: &outbuf [i] length: 1];
				}
		
			if (flbreak)
				break;
			}
		} /*while*/
 
	return [[d copy] autorelease];
	} /*dataWithBase64String*/
	
	
- (NSData *) parseBase64: (CFXMLTreeRef) tree {
	
	NSString *base64String = [self getElementValue: tree];
	NSData *d = [self dataWithBase64String: base64String];
	
	return (d);
	} /*parseBase64*/


- (id) parseValue: (CFXMLTreeRef) tree {
	
	CFXMLTreeRef childTree;
	NSString *name = nil;
	
	childTree = CFTreeGetChildAtIndex (tree, 0);
	
	if (childTree == nil) /*Empty value? It happens*/
		return (@"");
		
	name = [self getTreeName: childTree];
		
	if ([name isEqualToString: @"array"])
		return [self parseArray: childTree];

	if ([name isEqualToString: @"struct"])
		return [self parseStruct: childTree];

	if ([name isEqualToString: @"i4"])
		return [self parseInt: childTree];

	if ([name isEqualToString: @"int"])
		return [self parseInt: childTree];

	if ([name isEqualToString: @"boolean"])
		return (id) [self parseBoolean: childTree];

	if ([name isEqualToString: @"string"])
		return [self parseString: childTree];

	if ([name isEqualToString: @"double"])
		return [self parseDouble: childTree];

	if ([name isEqualToString: @"dateTime.iso8601"])
		return [self parseDateTime: childTree];

	if ([name isEqualToString: @"base64"])
		return [self parseBase64: childTree];
		
	return [self parseString: tree];
	} /*parseValue*/


@end
