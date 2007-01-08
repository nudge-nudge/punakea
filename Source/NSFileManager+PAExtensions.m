//
//  NSFileManager+PAExtensions.m
//  punakea
//
//  Created by Johannes Hoffart on 01.11.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "NSFileManager+PAExtensions.h"

@implementation NSFileManager (PAExtensions)

// Sets a file ref descriptor from a path, without following symlinks
// Based on OAAppKit's fillAEDescFromPath and an example in http://www.cocoadev.com/index.pl?FSMakeFSSpec
static OSErr BDSKFillAEDescFromPath(AEDesc *fileRefDescPtr, NSString *path, BOOL isSymLink)
{
    FSRef fileRef;
    AEDesc fileRefDesc;
    OSErr err;
	
    bzero(&fileRef, sizeof(fileRef));
    
    if (isSymLink) {
        // FSPathMakeRef follows symlinks, so we need to do a bit more here to get the descriptor for the symlink itself
        const UInt8 *parentPath;
        FSRef parentRef;
        HFSUniStr255 fileName;
        
        parentPath = (UInt8 *)[[path stringByDeletingLastPathComponent] fileSystemRepresentation];
        err = FSPathMakeRef(parentPath, &parentRef, NULL);
        if(err == noErr){
            [[path lastPathComponent] getCharacters:fileName.unicode];
            fileName.length = [[path lastPathComponent] length];
            if (fileName.length == 0)
                err = fnfErr;
            else 
                err = FSMakeFSRefUnicode(&parentRef, fileName.length, fileName.unicode, kTextEncodingFullName, &fileRef);
        }
    } else {
        err = FSPathMakeRef((UInt8 *)[path fileSystemRepresentation], &fileRef, NULL);
    }
    
    if (err != noErr) 
        return err;
	
    AEInitializeDesc(&fileRefDesc);
    err = AECreateDesc(typeFSRef, &fileRef, sizeof(fileRef), &fileRefDesc);
	
    // Omni says the Finder isn't very good at coercions, so we have to do this ourselves; however we don't want to lose symlinks
    if (err == noErr){
        if(isSymLink == NO)
            err = AECoerceDesc(&fileRefDesc, typeAlias, fileRefDescPtr);
        else
            err = AEDuplicateDesc(&fileRefDesc, fileRefDescPtr);
    }
    AEDisposeDesc(&fileRefDesc);
    
    return err;
}

static OSType finderSignatureBytes = 'MACS';

// Sets the Finder comment (Spotlight comment) field via the Finder; this method takes 0.01s to execute, vs. 0.5s for NSAppleScript
// Based on OAAppKit's setComment:forPath: and http://developer.apple.com/samplecode/MoreAppleEvents/MoreAppleEvents.html (which is dated)
- (BOOL)setComment:(NSString *)comment forURL:(NSURL *)fileURL;
{
    NSParameterAssert(comment != nil);
    NSParameterAssert([fileURL isFileURL]);
    NSString *path = [fileURL path];
	
	// do nothing if there is no file
	if (![self fileExistsAtPath:path])
	{
		return NO;
	}
	
    BOOL isSymLink = [[[self fileAttributesAtPath:path traverseLink:NO] objectForKey:NSFileType] isEqualToString:NSFileTypeSymbolicLink];
    BOOL success = YES;
    NSAppleEventDescriptor *commentTextDesc;
    OSErr err;
    AEDesc fileDesc, builtEvent;
    const char *eventFormat =
        "'----': 'obj '{ "         // Direct object is the file comment we want to modify
        "  form: enum(prop), "     //  ... the comment is an object's property...
        "  seld: type(comt), "     //  ... selected by the 'comt' 4CC ...
        "  want: type(prop), "     //  ... which we want to interpret as a property (not as e.g. text).
        "  from: 'obj '{ "         // It's the property of an object...
        "      form: enum(indx), "
        "      want: type(file), " //  ... of type 'file' ...
        "      seld: @,"           //  ... selected by an alias ...
        "      from: null() "      //  ... according to the receiving application.
        "              }"
        "             }, "
        "data: @";                 // The data is what we want to set the direct object to.
	
    commentTextDesc = [NSAppleEventDescriptor descriptorWithString:comment];
	
    
    AEInitializeDesc(&builtEvent);
    
    err = BDSKFillAEDescFromPath(&fileDesc, path, isSymLink);
	
    if (err == noErr)
        err = AEBuildAppleEvent(kAECoreSuite, kAESetData,
                                typeApplSignature, &finderSignatureBytes, sizeof(finderSignatureBytes),
                                kAutoGenerateReturnID, kAnyTransactionID,
                                &builtEvent, NULL,
                                eventFormat,
                                &fileDesc, [commentTextDesc aeDesc]);
	
    AEDisposeDesc(&fileDesc);
	
    if (err == noErr)
        err = AESendMessage(&builtEvent, NULL, kAENoReply, kAEDefaultTimeout);
	
    AEDisposeDesc(&builtEvent);
    
    if (err != noErr) {
        NSLog(@"Unable to set comment for file %@", fileURL);
        success = NO;
    }
    return success;
}

// Gets the Finder comment (Spotlight comment) field via the Finder; this method takes 0.01s to execute, vs. 0.5s for NSAppleScript
// Based on setComment:forPath: and http://developer.apple.com/samplecode/MoreAppleEvents/MoreAppleEvents.html (which is dated)
- (NSString *)commentForURL:(NSURL *)fileURL;
{
    NSParameterAssert([fileURL isFileURL]);
    
    OSErr err;
    AEDesc fileDesc, builtEvent, replyEvent;
    
    // create the format by modifying Omni's setComment:forPath: method and looking at the events in the debugger
    const char *eventFormat = 
        "'----': 'obj '{ "
        "  form: enum(prop), "
        "  seld: type(comt), "
        "  want: type(prop), "
        "  from: 'obj '{ " 
        "      form: enum(indx), "
        "      want: type(file), " 
        "      seld: @,"
        "      from: null() "
        "              }"
        "             } ";
    
    // pass a file URL, encoding as UTF8 after http://developer.apple.com/technotes/tn/tn2022.html
    NSData *URLData = [[fileURL absoluteString] dataUsingEncoding:NSUTF8StringEncoding];
    AEInitializeDesc(&fileDesc);
    err = AECreateDesc(typeFileURL, [URLData bytes], [URLData length], &fileDesc);
    
    AEInitializeDesc(&builtEvent);
    AEInitializeDesc(&replyEvent);
    AEBuildError error;
	
    if(noErr == err)
        err = AEBuildAppleEvent(kAECoreSuite, kAEGetData,
                                typeApplSignature, &finderSignatureBytes, sizeof(finderSignatureBytes),
                                kAutoGenerateReturnID, kAnyTransactionID,
                                &builtEvent, &error,
                                eventFormat,
                                &fileDesc);
    
    AEDisposeDesc(&fileDesc);
    
    if(noErr == err)
        err = AESendMessage(&builtEvent, &replyEvent, kAEWaitReply, kAEDefaultTimeout);
    AEDisposeDesc(&builtEvent);
    
	AEDesc replyDesc;
    AEInitializeDesc(&replyDesc);
    
    if(noErr == err)
        err = AEGetParamDesc(&replyEvent, keyDirectObject, typeUnicodeText, &replyDesc);
    AEDisposeDesc(&replyEvent);
    
    AEDesc utf8TextDesc;
    AEInitializeDesc(&utf8TextDesc);
    
    if(noErr == err)
        err = AECoerceDesc(&replyDesc, typeUTF8Text, &utf8TextDesc);
    AEDisposeDesc(&replyDesc);
    
    CFStringRef comment = NULL;
    if(noErr == err){
        Size dataSize = AEGetDescDataSize(&utf8TextDesc);
        CFIndex bufSize = dataSize;
        UInt8 *buf = (UInt8 *)NSZoneMalloc(NULL, bufSize * sizeof(UInt8));
        if(NULL != buf){
            err = AEGetDescData(&utf8TextDesc, buf, dataSize);
            if(noErr == err)
                comment = CFStringCreateWithBytes(CFAllocatorGetDefault(), buf, bufSize, kCFStringEncodingUTF8, FALSE);
            
            NSZoneFree(NULL, buf);
        }
    }
    AEDisposeDesc(&utf8TextDesc);    
    
    if (err != noErr) {
        NSLog(@"AESend() --> %d", err);
        if(GetMacOSStatusErrorString != NULL) 
            NSLog(@"Error was %s", GetMacOSStatusErrorString(err));
    }
    return [(id)comment autorelease];
}

@end
