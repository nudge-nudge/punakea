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
	XMLRPCCall.m

	Created by Brent Simmons on Thu Nov 14 2002.
	Copyright (c) 2002 Ranchero Software. All rights reserved.
*/


#import <CURLHandle/CURLHandle.h>
#import <CURLHandle/CURLHandle+extras.h>
#import "XMLRPCCall.h"
#import "XMLRPCRequest.h"
#import "XMLRPCResponse.h"


@implementation XMLRPCCall


- (id) init {
	
	xmlrpcRequest = [[XMLRPCRequest alloc] init];
	
	flParseError = NO;
	
	flDownloadError = NO;
	
	flNoData = NO;
	
	statusCode = -1;
	
	[self setUserAgent: @"XMLRPCCocoa"]; /*default*/
	
	return (self);
	} /*init*/
	

- (id) initWithURLString: (NSString *) s {
	
	[self init];
	
	[self setURLWithString: s];
	
	return (self);
	} /*initWithURLString*/
	
	
- (void) dealloc {
	
	[rpcURLString release];		
	
	[rpcURL release];
	
	[response release];
	
	[xmlrpcRequest release];
	
	[xmlrpcResponse release];
	
	[parseErrorTitle release];

	[parseErrorMessage release];
	
	[context release];
	
	[userAgent release];
	
	[requestText release];
	} /*dealloc*/


- (void) setURLWithString: (NSString *) s {
	
	if (rpcURLString != nil)
		[rpcURLString autorelease];
	
	if (s == nil)
		rpcURLString = nil;
	else
		rpcURLString = [s retain];
	
	if (rpcURL != nil)
		[rpcURL autorelease];
	
	if (s == nil)
		rpcURL = nil;
	else
		rpcURL = [[NSURL URLWithString: s] retain];
	} /*setURLWithString*/
	

/*Caller can set the User-Agent*/

- (NSString *) userAgent {
	
	return (userAgent);
	} /*userAgent*/
	

- (void) setUserAgent: (NSString *) s {
	
	if (userAgent != nil)
		[userAgent autorelease];
	
	if (s == nil)
		userAgent = nil;
	else
		userAgent = [s retain];
	} /*setUserAgent*/
	
	
/*Method name, parameters*/

- (void) setMethodName: (NSString *) s {

	[xmlrpcRequest setMethodName: s];
	} /*setMethodName*/
	

- (void) setParameters: (NSArray *) params {

	[xmlrpcRequest setParameters: params];
	} /*setParameters*/


/*Target, action, context*/

- (void) setTarget: (id) t {
	
	target = t;
	} /*setTarget*/
	

- (void) setAction: (SEL) a {
	
	action = a;
	} /*setAction*/
	

- (id) context {
		
	return (context);
	} /*context*/


- (void) setContext: (id) obj {
	
	if (context != nil)
		[context autorelease];
	
	if (obj == nil)
		context = nil;
	else
		context = [obj retain];	
	} /*setContext*/


/*Errors: parse/download errors and XML-RPC faults*/

- (BOOL) succeeded {
	
	/*
	Return YES -- unless there was some kind of error.
	*/
	
	if ([self isDownloadError])
		return (NO);
	
	if ([self isNoDataError])
		return (NO);
	
	if ([self isParseError])
		return (NO);
	
	if ([self isFault])
		return (NO);
	
	return (YES);
	} /*succeeded*/
	
	
- (BOOL) isDownloadError {
	
	return (flDownloadError);
	} /*isDownloadError*/


- (BOOL) isNoDataError {
	
	/*Returns YES in the case of a no-data error, where the server
	returned no data at all.*/
	
	return (flNoData);
	} /*isNoDataError*/


- (BOOL) isParseError {
	
	return (flParseError);
	} /*isParseError*/


- (NSString *) parseErrorTitle {
	
	return (parseErrorTitle);
	} /*parseErrorTitle*/


- (NSString *) parseErrorMessage {
	
	return (parseErrorMessage);
	} /*parseErrorMessage*/
	
	
- (void) setParseErrorTitle: (NSString *) s {
		
	if (parseErrorTitle != nil)
		[parseErrorTitle autorelease];
	
	if (s == nil)
		parseErrorTitle = nil;
	else
		parseErrorTitle = [s retain];	
	} /*setParseErrorTitle*/
	
	
- (void) setParseErrorMessage: (NSString *) s {

	if (parseErrorMessage != nil)
		[parseErrorMessage autorelease];
	
	if (s == nil)
		parseErrorMessage = nil;
	else
		parseErrorMessage = [s retain];	
	} /*setParseErrorMessage*/
	

- (BOOL) isFault {
	
	return [xmlrpcResponse isFault];
	} /*isFault*/
	

- (NSString *) faultString {
	
	return [xmlrpcResponse faultString];
	} /*faultString*/
	

- (int) faultCode {
	
	return [xmlrpcResponse faultCode];
	} /*faultCode*/
	

- (int) statusCode {
	
	/*
	The code -- 200, 404, etc. -- returned
	by the HTTP server.
	*/
	
	return (statusCode);
	} /*statusCode*/
	

/*Returned object -- the XML-RPC response as a Cocoa object*/

- (id) returnedObject {
	
	if (![self succeeded])
		return (nil);
	
	return [xmlrpcResponse returnedObject];
	} /*returnedObject*/


/*Request and response text. For debugging use.*/

- (NSString *) requestText {
		
	return (requestText);
	} /*requestText*/


- (NSString *) responseText {
	
	return [xmlrpcResponse responseText];
	} /*responseText*/
	
	
/*XML-RPC method invocation*/

- (void) invokeThread: (id) sender {
	
	/*
	PBS 02/03/03: run the callback on the main thread.
	*/
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	[self invoke];
	
	[target performSelectorOnMainThread: action withObject: self waitUntilDone: YES];

	[pool release];
	
	[self release];
	} /*invokeThread*/


- (void) invokeInNewThread: (id) callbackTarget callbackSelector: (SEL) callbackSelector {
	
	[self setTarget: callbackTarget];
	
	[self setAction: callbackSelector];
	
	[NSThread	detachNewThreadSelector: @selector (invokeThread:)
		toTarget: self withObject: nil];
	} /*invokeInNewThread*/


- (void) invoke {
	
	/*
	Create and send the XML-RPC request via HTTP. Parse the response.
	*/
	
	CURLHandle *urlHandle;
	NSDictionary *contentTypeHeader =
		[NSDictionary dictionaryWithObject: @"text/xml" forKey: @"Content-Type"];
	NSNumber *statusCodeNumber = nil;

	urlHandle = (CURLHandle *) [rpcURL URLHandleUsingCache: NO];
	
	if (userAgent != nil)
		[urlHandle setUserAgent: userAgent];
		
	[urlHandle setConnectionTimeout: 5];	
	
	[urlHandle setFollowsRedirects: YES];
	
	requestText = [[xmlrpcRequest requestText] retain];
	
	[urlHandle setPostString: [xmlrpcRequest requestText]];

	[urlHandle setHTTPHeaders: contentTypeHeader];
	
	response = [urlHandle resourceData];
	
	statusCodeNumber = [urlHandle propertyForKeyIfAvailable: NSHTTPPropertyStatusCodeKey];
		
	if (statusCodeNumber != nil)
		statusCode = [statusCodeNumber intValue];
	
	if (statusCode != 200)		
		flDownloadError = YES;

	if (response == nil) {
		
		flDownloadError = YES;
		
		if (statusCode == 200) /*no-data-error: 200 response with no data*/
			flNoData = YES;
		} /*if*/
	
	if (flDownloadError)
		return;
		
	NS_DURING	
	
		xmlrpcResponse = [[XMLRPCResponse alloc] initWithData: response];
		
		flParseError = NO;
		
	NS_HANDLER
	
		flParseError = YES;
		
		[self setParseErrorTitle: [localException name]];

		[self setParseErrorMessage: [localException reason]];
	
	NS_ENDHANDLER
	
	[response retain];
	} /*invoke*/


@end
