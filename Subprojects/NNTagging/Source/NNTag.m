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

#import "NNTag.h"

@implementation NNTag 

#pragma mark init
- (id)init
{
	return [self initWithName:NSLocalizedString(@"default tag name",@"tag")];
}

- (id)initWithName:(NSString*)aName 
{
	if (self = [super init]) 
	{
		[self setName:aName];		
		
		clickCount = 0;
		useCount = 0;
	}
	return self;
}

//designated initializer
- (id)initWithName:(NSString*)tagName
			 query:(NSString*)tagQuery
	   lastClicked:(NSDate*)clickDate
		  lastUsed:(NSDate*)useDate
		clickCount:(NSUInteger)clicks
		  useCount:(NSUInteger)uses
{
	if (self = [super init])
	{
		[self setName:tagName];
		[self setQuery:tagQuery];
		[self setLastClicked:clickDate];
		[self setLastUsed:useDate];
		[self setClickCount:clicks];
		[self setUseCount:uses];
	}
	
	return self;
}

- (void)dealloc 
{
	[lastUsed release];
	[lastClicked release];
	[name release];
	[query release];
	[super dealloc];
}


#pragma mark euality testing
- (BOOL)isEqual:(id)other
{
	return NO;
}

- (NSUInteger)hash 
{
	return 0;
}

- (id)copyWithZone:(NSZone *)zone
{
	return nil;
}


#pragma mark sqlite
- (BOOL)writeToTagDatabase
{	
	// tell tagStore about this update
	[[NNTagStoreManager defaultManager] signalTagDBUpdate];
	
	FMDatabase *db = [[NNTagStoreManager defaultManager] db];
	
	BOOL success = YES;
		
	@try {
		FMResultSet *rs = [db executeQuery:@"SELECT name FROM tags WHERE name=?",[self name],nil];
		
		if (![rs next])
		{
			[rs close];
			// the tag isn't in the db, yet, create
			success = success && [db executeUpdate:@"INSERT INTO tags VALUES (?, ?, ?, ?, ?, ?, ?)",
								  [self class], [self name], [self query],
								  [self lastClicked], [self lastUsed],
								  [NSNumber numberWithUnsignedLong:clickCount], [NSNumber numberWithUnsignedLong:useCount],
								  nil];
		}
		else
		{
			[rs close];
			// update tag
			success = success && [db executeUpdate:@"UPDATE tags SET class=?, name=?, query=?, lastClicked=?, lastUsed=?, clickCount=?, useCount=? WHERE name=?",
								  [self class], [self name], [self query],
								  [self lastClicked], [self lastUsed],
								  [NSNumber numberWithUnsignedLong:clickCount], [NSNumber numberWithUnsignedLong:useCount],
								  [self name], nil];
		}
	}
	@catch (NSException *e) {
		success = NO;
	}
		
	return success;
}

- (BOOL)removeFromTagDatabase
{
	// tell tagStore about this update
	[[NNTagStoreManager defaultManager] signalTagDBUpdate];
	
	FMDatabase *db = [[NNTagStoreManager defaultManager] db];
	
	BOOL success = YES;
	
	success = success && [db executeUpdate:@"DELETE FROM tags WHERE name=?",[self name],nil];
	
	return success;
}

#pragma mark nscoding
// DEPRECATED - only used by NNCompatbilityChecker!
- (id)initWithCoder:(NSCoder*)coder 
{
	self = [super init];
	if (self) 
	{
		[self setName:[coder decodeObjectForKey:@"name"]];
		[self setQuery:[coder decodeObjectForKey:@"query"]];
		lastClicked = [[coder decodeObjectForKey:@"lastClicked"] retain];
		lastUsed = [[coder decodeObjectForKey:@"lastUsed"] retain];
		[coder decodeValueOfObjCType:@encode(NSUInteger) at:&clickCount];
		[coder decodeValueOfObjCType:@encode(NSUInteger) at:&useCount];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder*)coder 
{
	[coder encodeObject:name forKey:@"name"];
	[coder encodeObject:query forKey:@"query"];
	[coder encodeObject:lastClicked forKey:@"lastClicked"];
	[coder encodeObject:lastUsed forKey:@"lastUsed"];
	[coder encodeValueOfObjCType:@encode(NSUInteger) at:&clickCount];
	[coder encodeValueOfObjCType:@encode(NSUInteger) at:&useCount];
}


#pragma mark Misc
- (void)renameTo:(NSString*)aName
{
	[self setName:aName];
}

- (CGFloat)absoluteRating
{
	return 0;
}

- (CGFloat)relativeRatingToTag:(NNTag*)otherTag
{	
	return 0;
}

- (void)remove
{
	// nothing
}

- (void)incrementClickCount
{	
	[self setLastClicked:[NSDate date]];
	[self setClickCount:clickCount+1];
}

- (void)incrementUseCount 
{
	[self setLastUsed:[NSDate date]];
	[self setUseCount:useCount+1];
}

- (void)decrementUseCount 
{	
	if (useCount > 0)
		[self setUseCount:useCount-1];
}


#pragma mark Acessors
- (NSString*)name 
{
	return name;
}

- (void)setName:(NSString*)aName 
{
	[self setName:aName decompose:YES];
}

- (void)setName:(NSString*)aName decompose:(BOOL)decompose
{
	[name release];
	
	if(decompose)
		name = [[aName decomposedStringWithCanonicalMapping] retain];
	else
		name = [aName retain];
}

- (NSString *)precomposedName
{
	return [name precomposedStringWithCanonicalMapping];
}

- (NSString*)query 
{
	return query;
}

- (NSString*)negatedQuery
{
	NSString *negatedQuery = [[self query] stringByReplacingOccurrencesOfString:@"==" withString:@"!="];
	
	return negatedQuery;
}

- (void)setQuery:(NSString*)aQuery 
{
	[aQuery retain];
	[query release];
	query = aQuery;
}

- (NSUInteger)useCount 
{
	return useCount;
}

- (void)setUseCount:(NSUInteger)count
{
	useCount = count;
}

- (NSUInteger)clickCount 
{
	return clickCount;
}

- (void)setClickCount:(NSUInteger)count
{
	clickCount = count;
}

- (NSArray*)taggedObjects
{
	return [NSArray array];
}

- (NSDate*)lastClicked 
{
	return lastClicked;
}

- (void)setLastClicked:(NSDate*)clickDate
{
	[clickDate retain];
	[lastClicked release];
	lastClicked = clickDate;
}

- (NSDate*)lastUsed 
{
	return lastUsed;
}

- (void)setLastUsed:(NSDate*)useDate
{
	[useDate retain];
	[lastUsed release];
	lastUsed = useDate;
}


#pragma mark drawing
- (NSMutableDictionary*)viewAttributes
{
	return nil;
}


#pragma mark comparison
- (NSComparisonResult)compare:(id)object
{
	if (![object isKindOfClass:[self class]])
	{
		return NSOrderedSame;
	}
	else
	{
		return [[self name] compare:[object name] options:NSCaseInsensitiveSearch];
	}
}	

- (NSComparisonResult)compareByRating:(id)object
{
	if (![object isKindOfClass:[self class]])
	{
		return NSOrderedSame;
	}
	else
	{
		NNTag *other = (NNTag *)object;
		
		if (self.absoluteRating < other.absoluteRating)
			return NSOrderedAscending;
		else if (self.absoluteRating > other.absoluteRating)
			return NSOrderedDescending;
		else
			return NSOrderedSame;
	}
}	


#pragma mark description
- (NSString*)description 
{
	return [NSString stringWithFormat:@"[%@] name: %@ - usecount: %lu - clickcount - %lu",[self class],name,useCount,clickCount];
}

@end