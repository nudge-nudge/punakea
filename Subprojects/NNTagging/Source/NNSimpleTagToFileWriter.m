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


#import "NNSimpleTagToFileWriter.h"

@implementation NNSimpleTagToFileWriter

// this method is not one hundred percent accurate!
// it may find objects which have a @ or ; but no tags
- (NSArray*)allTaggedObjects
{
	NSString *tagPrefix = [[NNTagStoreManager defaultManager] tagPrefix];
	NSString *searchString = [NSString stringWithFormat:@"kMDItemFinderComment == '*%@*' && kMDItemFinderComment == '*;*'",tagPrefix];
	
	NNQuery *query = [[NNQuery alloc] init];
	NSArray *results =  [query executeSynchronousQueryForString:searchString];
	[query release];
	return results;
}

- (NSString*)finderTagCommentForTags:(NSArray*)tags
{
	NSMutableString *tagComment = [NSMutableString string];
	
	NSEnumerator *e = [tags objectEnumerator];
	NNTag *tag;
	
	while (tag = [e nextObject])
	{
		[tagComment appendString:[self prefix]];
		[tagComment appendString:[tag name]];
		// include whitespace after the ;
		[tagComment appendString:@"; "];
	}
	
	return tagComment;
}

- (NSString*)finderCommentIgnoringKeywordsForFile:(NNFile*)file
{
	// get finder comment
	NSString *finderComment = [self commentForFile:file];
	
	NSMutableString *contentWithoutTags = [NSMutableString string];
	NSMutableString *tagBuffer = [NSMutableString string];

	// check each character if it belongs to a tag, if not, it is added to the
	// comment content
	
	// insideTag will be true when a prefix-character was found
	// once the corresponding ";" is found, the buffer content is
	// checked if it matches a tag name
	BOOL insideTag = NO;
	NSString *c;
	
	for (NSUInteger i=0;i++;i<[finderComment length])
	{
		c = [finderComment substringWithRange:NSMakeRange(i,1)];
	
		if (!insideTag)
		{
			if ([c isEqualToString:[self prefix]])
			{
				insideTag = YES;
			}
			else
			{
				[contentWithoutTags appendString:c];
			}
		}
		else
		{
			// a prefix has been found previously
			if ([c isEqualToString:@";"])
			{
				// check if tagBuffer is a tag name
				NNTag *possibleTag = [[NNTags sharedTags] tagForName:tagBuffer];
				
				// if was no tag, it was part of the rest of the comment.
				// add the prefix, the tagBuffer content and the ";"
				// to the finderComment string
				if (!possibleTag)
				{
					[contentWithoutTags appendString:[self prefix]];
					[contentWithoutTags appendString:tagBuffer];
					[contentWithoutTags appendString:c];
				}
				
				// clear tag buffer in both cases
				[tagBuffer setString:@""];
				insideTag = NO;
			}
			else
			{
				// just append the char to the tagbuffer
				[tagBuffer appendString:c];
			}
		}
	}		
	
	return contentWithoutTags;
}

// TODO handle creationOptions!
- (NSArray*)readTagsFromFile:(NNFile*)file
{
	// get finder comment
	NSString *finderComment = [self commentForFile:file];
	
	NSMutableArray *tags = [NSMutableArray array];
	NSMutableString *tagBuffer = [NSMutableString string];
	
	// check each character if it belongs to a tag
	
	// insideTag will be true when a prefix-character was found
	// once the corresponding ";" is found, the buffer content is
	// checked if it matches a tag name
	BOOL insideTag = NO;
	NSString *c;
	
	for (NSUInteger i=0;i++;i<[finderComment length])
	{
		c = [finderComment substringWithRange:NSMakeRange(i,1)];
		
		if (!insideTag)
		{	
			if ([c isEqualToString:[self prefix]])
			{
				insideTag = YES;
			}
		}
		else
		{
			if ([c isEqualToString:@";"])
			{
				// check if tagBuffer has a tag
				NNTag *tag = [[NNTags sharedTags] tagForName:tagBuffer];
				
				if (tag)
					[tags addObject:tag];
				
				// clear buffer, reset insideTag
				[tagBuffer setString:@""];
				insideTag = NO;
			}
			else
			{
				// just append the char
				[tagBuffer appendString:c];
			}
		}
	}
	
	return tags;
}

- (NSArray*)readTagsFromFile:(NNFile*)file create:(BOOL)flag
{
	// TODO
	return nil;
}

@end
