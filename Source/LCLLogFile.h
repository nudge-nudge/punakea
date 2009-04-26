//
//
// LCLLogFile.h
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
#import <Foundation/Foundation.h>

#define _LCLLOGFILE_VERSION_MAJOR  1
#define _LCLLOGFILE_VERSION_MINOR  0
#define _LCLLOGFILE_VERSION_BUILD  2

//
// LCLLogFile
//
// LCLLogFile is a LibComponentLogging logger implementation which writes
// log messages to an application-specific log file.
//
// The log file is opened automatically when the first log message needs to be
// written to the log file. There is no need to call open, close, reset, etc.
// manually.
//
// The log file gets rotated if a given maximum file size is reached.
//
// LCLLogFile is configured via the following defines which should be specified
// in lcl_config_logger.h:
//
// - Full path of the log file (type NSString)
//   #define _LCLLogFile_LogFilePath <definition>
//
// - Maximum size of the log file in bytes (type size_t)
//   #define _LCLLogFile_MaxLogFileSizeInBytes <definition>
//
// - Mirror log messages to stderr? (type BOOL)
//   #define _LCLLogFile_MirrorMessagesToStdErr <definition>
//


//
// LCLLogFile class.
//


@interface LCLLogFile : NSObject {
    
}

// Returns the path of the log file as defined by _LCLLogFile_LogFilePath.
+ (NSString *)path;

// Returns the path of the backup log file.
+ (NSString *)path0;

// Opens the log file.
+ (void)open;

// Closes the log file.
+ (void)close;

// Resets the log file.
+ (void)reset;

// Rotates the log file.
+ (void)rotate;

// Returns the current size of the log file.
+ (size_t)size;

// Returns the maximum size of the log file as defined by
// _LCLLogFile_MaxLogFileSizeInBytes.
+ (size_t)maxSize;

// Returns whether log messages are mirrored to stderr
+ (BOOL)mirrorsToStdErr;

// Returns the version of LCLLogFile.
+ (NSString *)version;

// Writes the given log message to the log file.
+ (void)writeComponent:(_lcl_component_t)component level:(_lcl_level_t)level
                  path:(const char *)path line:(uint32_t)line
               message:(NSString *)message, ... __attribute__((format(__NSString__, 5, 6)));

@end


//
// Integration with LibComponentLogging Core.
//


// Definition of _lcl_logger.
#define _lcl_logger(log_component, log_level, log_format, ...) {               \
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];                \
    [LCLLogFile writeComponent:log_component                                   \
                         level:log_level                                       \
                          path:__FILE__                                        \
                          line:__LINE__                                        \
                       message:log_format,                                     \
                            ## __VA_ARGS__];                                   \
    [pool release];                                                            \
}

