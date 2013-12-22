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

#import "NNSimpleTag.h"

#import "NNFile.h"
#import "NNTagging.h"

@interface NNSimpleTag (PrivateAPI)

- (BOOL)isEqualToTag:(NNSimpleTag*)otherTag;

@end

@implementation NNSimpleTag

#pragma mark functionality
// overwriting super-class methods
- (void)setName:(NSString*)aName 
{
	// ";" and ":" is not allowed in tag names at the moment
	// replace by _
	NSMutableString *cleanedName = [aName mutableCopy];
	[cleanedName replaceOccurrencesOfString:@";"
								 withString:@"_"
									options:0
									  range:NSMakeRange(0,[cleanedName length])];
	
	[cleanedName replaceOccurrencesOfString:@":"
								 withString:@"_"
									options:0
									  range:NSMakeRange(0,[cleanedName length])];
	
	[cleanedName replaceOccurrencesOfString:@"/"
								 withString:@"_"
									options:0
									  range:NSMakeRange(0,[cleanedName length])];
	
	[super setName:cleanedName];
	[cleanedName release];
}

- (NSString*)query
{
	NSString *queryString = [[[NNTagStoreManager defaultManager] tagToFileWriter] queryStringForTag:self];
	
	return queryString;
}

- (void)renameTo:(NSString*)aName
{
	// search for files
	NSArray *objects = [self taggedObjects];
	
	// delete old tag from db - it will be written again because the name change
	// triggers the writeTagToDatabase function (via NNTags tagsHaveChanged:)
	[self removeFromTagDatabase];
	
	// set new name
	[super renameTo:aName];
	
	// update files
	[objects makeObjectsPerformSelector:@selector(initiateSave)];
}

- (void)remove
{
	NSArray *objects = [self taggedObjects];
	[objects makeObjectsPerformSelector:@selector(removeTag:) withObject:self];
}

// implementing needed super-class methods
- (CGFloat)absoluteRating
{
	// default to value of NNTags
	CGFloat clickCountWeight = [[NNTags sharedTags] tagClickCountWeight];
	
	// check if app has weight set
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"TagCloud.ClickCountWeight"])
	{
		clickCountWeight = [[NSUserDefaults standardUserDefaults] floatForKey:@"TagCloud.ClickCountWeight"];
	}
	
	CGFloat useCountWeight = 1.0 - clickCountWeight;

	// + 1 because of logarithm, might be < 0 otherwise
	CGFloat rating = 1 + clickCountWeight*(CGFloat)[self clickCount] + useCountWeight*(CGFloat)[self useCount];
		
	return log10(rating);
}

- (CGFloat)relativeRatingToTag:(NNTag*)otherTag
{	
	return [self absoluteRating] / [otherTag absoluteRating];
}

#pragma mark euality testing
- (BOOL)isEqual:(id)other 
{
	if (!other || ![self isKindOfClass:[other class]]) 
        return NO;
    if (other == self)
        return YES;
	
    return [self isEqualToTag:other];
}

- (BOOL)isEqualToTag:(NNSimpleTag*)otherTag 
{
	if ([[self name] isEqual:[otherTag name]])
		return YES;
	else
		return NO;
}

- (NSUInteger)hash 
{
	return [name hash];
}

#pragma mark copying
- (id)copyWithZone:(NSZone *)zone
{
	NNSimpleTag *newTag = [[NNSimpleTag alloc] init];
	[newTag setName:[self name]];
	[newTag setUseCount:[self useCount]];
	[newTag setValue:[self lastUsed] forKey:@"lastUsed"];
	[newTag setClickCount:[self clickCount]];
	[newTag setValue:[self lastClicked]  forKey:@"lastClicked"];
	return newTag;
}

#pragma mark synchronous searching
- (NSArray*)taggedObjects
{
	return [[NNTagging tagging] taggedObjectsForTag:self];
}

@end