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
	XMLRPCCall.h

	Created by Brent Simmons on Thu Nov 14 2002.
	Copyright (c) 2002 Ranchero Software. All rights reserved.
*/

/*
Version: 1.0b1
*/


#import <Foundation/Foundation.h>


@class XMLRPCRequest;
@class XMLRPCResponse;


@interface XMLRPCCall : NSObject {

	NSString *rpcURLString;
	NSURL *rpcURL;
	NSData *response;
	id target;
	SEL action;
	XMLRPCRequest *xmlrpcRequest;
	XMLRPCResponse *xmlrpcResponse;
	NSString *parseErrorTitle;
	NSString *parseErrorMessage;
	BOOL flParseError, flDownloadError, flNoData;
	id context;
	int statusCode;
	NSString *userAgent;
	NSString *requestText;
	}


- (id) init;	

- (id) initWithURLString: (NSString *) s;	
	
- (void) dealloc;

- (void) setURLWithString: (NSString *) s;
	

/*Caller can set the User-Agent*/

- (NSString *) userAgent;	

- (void) setUserAgent: (NSString *) s;
	
	
/*Method name, parameters*/

- (void) setMethodName: (NSString *) s;	

- (void) setParameters: (NSArray *) params;


/*Target, action, context*/

- (void) setTarget: (id) t;	

- (void) setAction: (SEL) a;	

- (id) context;

- (void) setContext: (id) obj;


/*Errors: parse/download errors and XML-RPC faults*/

- (BOOL) succeeded;	
	
- (BOOL) isDownloadError;

- (BOOL) isNoDataError;

- (BOOL) isParseError;

- (NSString *) parseErrorTitle;

- (NSString *) parseErrorMessage;	
	
- (void) setParseErrorTitle: (NSString *) s;	
	
- (void) setParseErrorMessage: (NSString *) s;	

- (BOOL) isFault;	

- (NSString *) faultString;	

- (int) faultCode;	

- (int) statusCode;


/*Returned object -- the XML-RPC response as a Cocoa object*/

- (id) returnedObject;


/*Request and response text. For debugging use.*/

- (NSString *) requestText;

- (NSString *) responseText;	


/*XML-RPC method invocation*/

- (void) invokeThread: (id) sender;

- (void) invokeInNewThread: (id) callbackTarget callbackSelector: (SEL) callbackSelector;

- (void) invoke;


@end
