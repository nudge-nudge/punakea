//
//
// lcl_config_logger.h
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


// Use LCLLogFile as the logging backend.
#import "LCLLogFile.h"

// Tell LCLLogFile the path of the log file as an NSString.
#define _LCLLogFile_LogFilePath                                                \
    [NSHomeDirectory() stringByAppendingPathComponent:                         \
        @"Library/Logs/NNTagging.log"]

// Tell LCLLogFile the maximum size of a log file in bytes.
#define _LCLLogFile_MaxLogFileSizeInBytes                                      \
    64 * 1024

// Tell LCLLogFile whether it should mirror the log messages to stderr
#define _LCLLogFile_MirrorMessagesToStdErr                                     \
    NO

