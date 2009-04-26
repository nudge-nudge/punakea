//
//
// LCLLogFile.m
//
//
// Copyright (c) 2008-2009 Arne Harren <ah@0xc0.de>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "lcl.h"

#ifndef _LCLLogFile_LogFilePath
#error  '_LCLLogFile_LogFilePath' must be defined in 'lcl_config_logger.h'
#endif

#ifndef _LCLLogFile_MaxLogFileSizeInBytes
#error  '_LCLLogFile_MaxLogFileSizeInBytes' must be defined in 'lcl_config_logger.h'
#endif

#ifndef _LCLLogFile_MirrorMessagesToStdErr
#error  '_LCLLogFile_MirrorMessagesToStdErr' must be defined in 'lcl_config_logger.h'
#endif

#include <unistd.h>
#include <mach/mach_init.h>
#include <sys/time.h>


@interface LCLLogFile (Internals)

// A lock which is held when the log file is used, opened, etc.
static NSRecursiveLock *_LCLLogFile_fileLock = nil;

// A handle to the current log file, if opened.
static volatile FILE *_LCLLogFile_fileHandle = NULL;

// YES, if logging is active.
static volatile BOOL _LCLLogFile_isActive = NO;

// YES, if log messages should be mirrored to stderr.
static BOOL _LCLLogFile_mirrorToStdErr = NO;

// Max size of log file.
static size_t _LCLLogFile_fileSizeMax = 0;

// Current size of log file.
static size_t _LCLLogFile_fileSize = 0;

// Paths of log files.
static NSString *_LCLLogFile_filePath = nil;
static const char *_LCLLogFile_filePath_c = NULL;
static NSString *_LCLLogFile_filePath0 = nil;
static const char *_LCLLogFile_filePath0_c = NULL;

// The process id.
static pid_t _LCLLogFile_processId = 0;

// Initializes the class.
+ (void)initialize;

@end


@implementation LCLLogFile

// No instances, please.
+(id)alloc {
    [LCLLogFile doesNotRecognizeSelector:_cmd];
    return nil;
}

// Initializes the class.
+ (void)initialize {
    // perform initialization only once
    if (self != [LCLLogFile class])
        return;
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // create the lock
    _LCLLogFile_fileLock = [[NSRecursiveLock alloc] init];
    
    // get the process id
    _LCLLogFile_processId = getpid();
    
    // get the max file size
    _LCLLogFile_fileSizeMax = (_LCLLogFile_MaxLogFileSizeInBytes);
    
    // get whether we should mirror log messages to stderr
    _LCLLogFile_mirrorToStdErr = (_LCLLogFile_MirrorMessagesToStdErr);
    
    // get the full path of the log file
    NSString *path = (_LCLLogFile_LogFilePath);
    path = [path stringByStandardizingPath];
    
    // create parent paths for the log file
    NSString *parentpath = [path stringByDeletingLastPathComponent];
    [[NSFileManager defaultManager] createDirectoryAtPath:parentpath
                              withIntermediateDirectories:YES 
                                               attributes:nil
                                                    error:NULL];
    
    // create local copies of the log file paths
    _LCLLogFile_filePath = [path copy];
    _LCLLogFile_filePath_c = strdup([_LCLLogFile_filePath fileSystemRepresentation]);
    _LCLLogFile_filePath0 = [[path stringByAppendingString:@".0"] copy];
    _LCLLogFile_filePath0_c = strdup([_LCLLogFile_filePath0 fileSystemRepresentation]);
    
    // log file size is zero
    _LCLLogFile_fileSize = 0;
    
    [pool release];
}

// Returns the path of the log file.
+ (NSString *)path {
    return _LCLLogFile_filePath;
}

// Returns the path of the backup log file.
+ (NSString *)path0 {
    return _LCLLogFile_filePath0;
}

// Opens the log file.
+ (void)open {
    [_LCLLogFile_fileLock lock];
    {
        if (_LCLLogFile_fileHandle == NULL) {
            if (!_LCLLogFile_isActive) {
                // reset the log file if this is the first call to open 
                [LCLLogFile reset];
            }
            
            // open the log file
            _LCLLogFile_fileHandle = fopen(_LCLLogFile_filePath_c, "w");
            
            // log file size is zero
            _LCLLogFile_fileSize = 0;
            
            // logging is active
            _LCLLogFile_isActive = YES;
        }
    }
    [_LCLLogFile_fileLock unlock];
}

// Closes the log file.
+ (void)close {
    [_LCLLogFile_fileLock lock];
    {
        // close the log file
        FILE *filehandle = (FILE *)_LCLLogFile_fileHandle;
        if (filehandle != NULL) {
            fclose(filehandle);
            _LCLLogFile_fileHandle = NULL;
        }
        
        // log file size is zero
        _LCLLogFile_fileSize = 0;
    }
    [_LCLLogFile_fileLock unlock];
}

// Resets the log file.
+ (void)reset {
    [_LCLLogFile_fileLock lock];
    {
        // close the log file
        [LCLLogFile close];
        
        // unlink existing log files
        unlink(_LCLLogFile_filePath_c);
        unlink(_LCLLogFile_filePath0_c);
                
        // logging is not active
        _LCLLogFile_isActive = NO;
        
    }
    [_LCLLogFile_fileLock unlock];
}

// Rotates the log file.
+ (void)rotate {
    [_LCLLogFile_fileLock lock];
    {
        // close the log file
        [LCLLogFile close];
        
        // keep a copy of the current log file
        rename(_LCLLogFile_filePath_c, _LCLLogFile_filePath0_c);
    }
    [_LCLLogFile_fileLock unlock];
}

// Returns the current size of the log file.
+ (size_t)size {
    size_t sz = 0;
    [_LCLLogFile_fileLock lock];
    {
        // get the size
        sz = _LCLLogFile_fileSize;
    }
    [_LCLLogFile_fileLock unlock];
    return sz;
}

// Returns the maximum size of the log file.
+ (size_t)maxSize {
    return _LCLLogFile_fileSizeMax;
}

// Returns whether log messages are mirrored to stderr
+ (BOOL)mirrorsToStdErr {
    return _LCLLogFile_mirrorToStdErr;
}

// Returns the version of LCLLogFile.
+ (NSString *)version {
#define __lcl_version_to_string( _text) __lcl_version_to_string0(_text)
#define __lcl_version_to_string0(_text) #_text
    return @__lcl_version_to_string(_LCLLOGFILE_VERSION_MAJOR) 
        "." __lcl_version_to_string(_LCLLOGFILE_VERSION_MINOR)
        "." __lcl_version_to_string(_LCLLOGFILE_VERSION_BUILD);
}

// Writes the given log message to the log file (checked).
+ (void)writeComponent:(_lcl_component_t)component level:(_lcl_level_t)level
                  path:(const char *)path line:(uint32_t)line
               message:(NSString *)message, ... {
    // open the log file
    if (!_LCLLogFile_isActive) {
        [LCLLogFile open];
    }
    
    // write log message if the log file is opened
    if (_LCLLogFile_fileHandle) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        // variables for current time
        struct timeval now;
        struct tm now_tm;
        char time_c[24];        
        
        // get file from path
        const char *file = strrchr(path, '/');
        file = (file != NULL) ? (file + 1) : (path);
        
        // create log message
        va_list args;
        va_start(args, message);
        NSString *msg = [NSString stringWithFormat:@" %u:%x %s %s:%s:%u %@\n",
                         _LCLLogFile_processId,
                         mach_thread_self(),
                         _lcl_level_header_1[level],
                         _lcl_component_header[component],
                         file,
                         line,
                         [[[NSString alloc] initWithFormat:message arguments:args] autorelease]];
        va_end(args);
        
        // create log message as C string
        const char *msg_c = [msg UTF8String];
        size_t msg_c_time_c_len = strlen(msg_c) + sizeof(time_c);
        
        // under lock protection ...
        [_LCLLogFile_fileLock lock];
        {
            FILE *filehandle = (FILE *)_LCLLogFile_fileHandle;
            
            // rotate the log file if required
            if (filehandle) {
                if (_LCLLogFile_fileSize + msg_c_time_c_len > _LCLLogFile_fileSizeMax) {
                    [LCLLogFile rotate];
                    [LCLLogFile open];
                    filehandle = (FILE *)_LCLLogFile_fileHandle;
                }
            }
            
            // write the log message 
            if (filehandle) {
                // increase file size
                _LCLLogFile_fileSize += msg_c_time_c_len;
                
                // get current time
                gettimeofday(&now, NULL);
                localtime_r(&now.tv_sec, &now_tm);
                snprintf(time_c, sizeof(time_c), "%04d-%02d-%02d %02d:%02d:%02d.%03d", 
                         now_tm.tm_year + 1900,
                         now_tm.tm_mon + 1,
                         now_tm.tm_mday,
                         now_tm.tm_hour,
                         now_tm.tm_min,
                         now_tm.tm_sec,
                         now.tv_usec / 1000);
                
                // write current time and log message
                fprintf(filehandle, "%s%s", time_c, msg_c);
                
                // flush the file
                fflush(filehandle);
            }
            
            // mirror to stderr?
            if (_LCLLogFile_mirrorToStdErr) {
                fprintf(stderr, "%s%s", time_c, msg_c);
            }
        }
        // ... done
        [_LCLLogFile_fileLock unlock];
        
        [pool release];
    }
}

@end
