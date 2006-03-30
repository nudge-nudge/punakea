//
//  PATag.m
//  punakea
//
//  Created by Johannes Hoffart on 15.02.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PATag.h"

@implementation PATag 

#pragma mark init

//designated initializer
- (id)initWithName:(NSString*)aName 
{
	return nil;
}

//NSCoding
- (id)initWithCoder:(NSCoder*)coder 
{
	return nil;
}

- (void)encodeWithCoder:(NSCoder*)coder 
{

}

#pragma mark accessors
- (void)setName:(NSString*)aName 
{

}

- (void)setQuery:(NSString*)aQuery 
{

}

- (void)incrementClickCount 
{

}

- (void)incrementUseCount 
{

}

- (void)setCurrentBestTag:(PATag*)aTag
{

}

- (PATag*)currentBestTag 
{
	return nil;
}

- (NSString*)name 
{
	return nil;
}

- (NSString*)query 
{
	return nil;
}

- (NSCalendarDate*)lastClicked 
{
	return nil;
}

- (NSCalendarDate*)lastUsed 
{
	return nil;
}

- (unsigned long)clickCount 
{
	return 0;
}

- (unsigned long)useCount 
{
	return 0;
}

- (float)absoluteRating
{
	return 0;
}

- (float)relativeRating
{	
	return 0;
}

#pragma mark drawing
//TODO not HERE!
- (NSMutableDictionary*)viewAttributes
{
	return nil;
}

- (NSSize)sizeWithAttributes:(NSDictionary*)attributes
{
	return NSMakeSize(0,0);
}

#pragma mark euality testing
- (BOOL)isEqual:(id)other 
{
	return NO;
}

- (BOOL)isEqualToTag:(PATag*)otherTag 
{
	return NO;
}

- (unsigned)hash 
{
	return 0;
}

@end