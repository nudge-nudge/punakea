// Copyright (c) 2006-2013 nudge:nudge (Johannes Hoffart & Daniel Bär). All rights reserved.
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


#import <Cocoa/Cocoa.h>

#import "NNTagToFinderCommentWriter.h"

extern NSString * const TAGGER_OPEN_COMMENT;
extern NSString * const TAGGER_CLOSE_COMMENT;

/**
writes Finder Spotlight Comments with the syntax:
 <pre>###begin_tags###[prefix]tag1;[prefix]tag2;...[prefix]tagN;###end_tags###</pre>
 
 this is the preferred way to store tags in the finder comment,
 in order to separate the tags completely from the rest
 of the comment content - tags are very unlikely to get mixed up
 with user generated content.
  */
@interface NNSecureTagToFileWriter : NNTagToFinderCommentWriter

@end
