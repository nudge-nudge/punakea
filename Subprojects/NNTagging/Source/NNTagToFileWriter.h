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

#import "NNTagStoreManager.h"

#import "NNQuery.h"
#import "NNTags.h"

@class NNFile;

/**
Abstract class 
 
 This abstract class provides the interface for
 all TagToFile writers.
  */
@interface NNTagToFileWriter : NSObject {

}

/**
 Abstract method.
 
 @return All objects tagged with this TagToFileWriter
 */
- (NSArray*)allTaggedObjects;

/**
 Abstract method.
 
 Writes all given tags to the file, overwriting any previous tags.
 Be careful to include any tags already present on the file!
 
 @param tags	Array of NNTags to write to file
 @param file	File to write the tags to
 @return		YES if tags were written successfully, NO otherwise
 */
- (BOOL)writeTags:(NSArray*)tags toFile:(NNFile*)file;

/**
 Calls readTagsFromFiles:creationOptions with NNTagsCreationOptionFull by default.
 May be overwritten by subclass if appropriate.

 @param file	Dile to get tags for
 @return		Array of NNTags on file
 */
- (NSArray*)readTagsFromFile:(NNFile*)file;

/**
 Abstract method.
 
 @param file	File to get tags for
 @param options Influence tag creation
 @return		Array of NNTags on file
 */
- (NSArray*)readTagsFromFile:(NNFile*)file 
			 creationOptions:(NNTagsCreationOptions)options;

/**
 Abstract method.
 
 @param	tag	NNSimpleTag to create query for
 @return	Query String for NNSimpleTag
 */
- (NSString*)queryStringForTag:(NNSimpleTag*)tag;

/**
 Abstract method.
 
 @param	tag		NNSimpleTag to create query for
 @param negated YES if tag should be negated, NO otherwise
 @return	Query String for NNSimpleTag
 */
- (NSString*)queryStringForTag:(NNSimpleTag*)tag negated:(BOOL)negated;

/**
 Abstract method.
 
 @return	Spotlight metadata field the tags are stored in
 */
- (NSString*)spotlightMetadataField;

/**
 Abstract method.
 
 @return	Scope limiter in Spotlight query format
 */
- (NSString*)scopeLimiter;

/**
 Abstract method.
 
 @param	tagsSpotlightMetadataFieldValue	Value of the spotlight field where the tag metadata is stored
 @return								NSArray of NSStrings with the names of the tags
 */
- (NSArray*)extractTagNamesFromSpotlightMetadataFieldValue:(id)tagsSpotlightMetadataFieldValue;


@end
