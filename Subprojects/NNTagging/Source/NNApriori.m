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

#import "NNApriori.h"

@interface NNApriori (PrivateAPI)

+ (void)filterItemsets:(NSMutableDictionary*)itemsets minFreq:(NSUInteger)minFreq;
+ (NSMutableDictionary*)countOccurences:(NSSet*)itemsets tagsets:(NSArray*)tagsets;
+ (NSMutableSet*)generateCandidateSetFromFrequentItems:(NSSet*)frequentItems forLength:(NSUInteger)k;
+ (NSArray*)generateAssociationRulesForItemset:(NSArray*)itemset minConfidence:(CGFloat)minConfidence;
+ (BOOL)nextMask:(NSMutableArray*)mask;
+ (NSArray*)associationRules:(NSArray*)frequentItemsets minConfidence:(CGFloat)minConfidence;
+ (NSUInteger)support:(NSArray*)itemset;

@end

@implementation NNApriori

/**
 * Converts tag sets to sets of tag names, then calls the real method
 */
+ (NSArray*)frequentItemsetsForTagSets:(NSArray*)tagsets minFreq:(NSUInteger)minFreq 
{
	NSMutableArray *tagnameSets = [NSMutableArray arrayWithCapacity:[tagsets count]];
	
	for (NSArray *tagset in tagsets) 
	{
		NSArray *tagnameSet = [[NNTagging tagging] tagNamesForTags:tagset];
		[tagnameSets addObject:tagnameSet];
	}
	
	return [NNApriori frequentItemsetsForTagnameSets:tagnameSets minFreq:minFreq];
}

/**
 * Returns an array of itemsets that occur in the given transactions with at least the
 * specified frequency
 */
+ (NSArray*)frequentItemsetsForTagnameSets:(NSArray*)tagnameSets minFreq:(NSUInteger)minFreq
{		
	NSMutableDictionary *itemsets = [NSMutableDictionary dictionary];
	for (NSSet *tagset in tagnameSets)
	{
		for (NSString *tag in tagset)
		{
			NSMutableArray *tagSingleton = [NSMutableArray arrayWithObject:tag];
			NSNumber *frequency = [itemsets objectForKey:tagSingleton];
			if (frequency == nil)
				[itemsets setObject:[NSNumber numberWithInteger:1] forKey:tagSingleton];
			else 
				[itemsets setObject:[NSNumber numberWithInteger:[frequency integerValue]+1] forKey:tagSingleton];
		}
	}
	[NNApriori filterItemsets:itemsets minFreq:minFreq];
	
	NSMutableDictionary *frequentItemsets = [NSMutableDictionary dictionary];
	NSMutableDictionary *generatedItemsets = itemsets;
	
	NSUInteger k = 1;
	while ([generatedItemsets count] > 0) 
	{
		NSSet *frequentItemset = [NSSet setWithArray:[generatedItemsets allKeys]];
		NSMutableSet *joinedItemsets = [NNApriori generateCandidateSetFromFrequentItems:frequentItemset forLength:++k];
		generatedItemsets = [NNApriori countOccurences:joinedItemsets tagsets:tagnameSets];
		[NNApriori filterItemsets:generatedItemsets minFreq:minFreq];
		[frequentItemsets addEntriesFromDictionary:generatedItemsets];
	}
	
	return [frequentItemsets allKeys];
}

/**
 * Removes all itemsets which don't satisfy the minimum required frequency
 */
+ (void)filterItemsets:(NSMutableDictionary*)itemsets minFreq:(NSUInteger)minFreq 
{
	NSMutableArray *filteredItems = [NSMutableArray array];
	for (NSMutableArray *tagNames in itemsets) 
	{
		NSNumber *frequency = [itemsets objectForKey:tagNames];
			if ([frequency unsignedIntegerValue] < minFreq) 
				[filteredItems addObject:tagNames];
	}
	[itemsets removeObjectsForKeys:filteredItems];
}

/**
 * Takes the given frequentItems (of length k-1) and generates
 * a candidate set by joining them
 */
+ (NSMutableSet*)generateCandidateSetFromFrequentItems:(NSSet*)frequentItems forLength:(NSUInteger)k 
{
	NSMutableSet *candidates = [NSMutableSet set];
	
	for (NSArray *item in frequentItems) 
	{
		for (NSArray *innerItem in frequentItems) 
		{
			// check for matching prefix
			BOOL matching = YES; 
			
			for (NSUInteger i=0;i<k-2;i++) 
			{
				if (![[item objectAtIndex:i] isEqualToString:[innerItem objectAtIndex:i]]) 
				{
					matching = NO;
					break;
				}
			}
			
			// if the prefix matches, create candidate if item[k-2] < innerItem[k-2]
			if (matching) 
			{
				NSString *lastItemObject = [item objectAtIndex:k-2];
				NSString *lastInnerItemObject = [innerItem objectAtIndex:k-2];
				NSComparisonResult result = [lastItemObject compare:lastInnerItemObject];
				
				if (result == NSOrderedAscending) 
				{
					NSMutableArray *candidate = [NSMutableArray array];
					
					for (NSUInteger i=0;i<k-2;i++) 
						[candidate addObject:[item objectAtIndex:i]];
					
					// add differing items
					[candidate addObject:lastItemObject];
					[candidate addObject:lastInnerItemObject];
					
					// add to candidates
					[candidates addObject:candidate];
				}
			}
		}
	}
	
	return candidates;
}

/**
 * Counts the number of occurences of the specified itemsets in the tagsets and returns
 * a hashmap that maps each of the itemsets to its occurence count
 */
+ (NSMutableDictionary*)countOccurences:(NSSet*)itemsets tagsets:(NSArray*)tagsets 
{
	NSMutableDictionary *itemsetCounts = [NSMutableDictionary dictionary];

	for (NSArray *tagset in tagsets) 
	{
		for (NSArray *itemset in itemsets) 
		{
			BOOL tagsetContainsItems = YES;
			for (NSString *tag in itemset) 
			{
				if (![tagset containsObject:tag]) 
				{
					tagsetContainsItems = NO;
					break;
				}
			}
			
			if (tagsetContainsItems) 
			{
				NSNumber *frequency = [itemsetCounts objectForKey:itemset];
				if (frequency == nil)
					[itemsetCounts setObject:[NSNumber numberWithInteger:1] forKey:itemset];
				else
					[itemsetCounts setObject:[NSNumber numberWithInteger:[frequency integerValue]+1] forKey:itemset];
			}
		}
	}
	
	return itemsetCounts;
}

/**
 * Generates the array of association rules that satisfy the given confidence level for the specified array of
 * transactions (tagsets) of tags, considering all itemsets with at least the given frequency
 */
+ (NSArray*)associationRulesForTagSets:(NSArray*)tagsets minFreq:(NSUInteger)minFreq minConfidence:(CGFloat)minConfidence
{
	return [NNApriori associationRules:[NNApriori frequentItemsetsForTagSets:tagsets minFreq:minFreq] minConfidence:minConfidence];
}

/**
 * Generates the array of association rules that satisfy the given confidence level for the specified array of
 * transactions (tagsets) of tag names, considering all itemsets with at least the given frequency
 */
+ (NSArray*)associationRulesForTagnameSets:(NSArray*)tagsets minFreq:(NSUInteger)minFreq minConfidence:(CGFloat)minConfidence
{
	return [NNApriori associationRules:[NNApriori frequentItemsetsForTagnameSets:tagsets minFreq:minFreq] minConfidence:minConfidence];
}

/**
 * Returns association rules with at least the specified confidence from the given array
 * of frequent itemsets
 */
+ (NSArray*)associationRules:(NSArray*)frequentItemsets minConfidence:(CGFloat)minConfidence
{
	NSMutableArray *rules = [NSMutableArray array];
	for (NSArray *itemset in frequentItemsets)
		[rules addObjectsFromArray:[NNApriori generateAssociationRulesForItemset:itemset minConfidence:minConfidence]];
	return rules;
}

/**
 * Generates association rules for the specified itemset that possess at least the given
 * confidence value
 */
+ (NSArray*)generateAssociationRulesForItemset:(NSArray*)itemset minConfidence:(CGFloat)minConfidence 
{
	NSMutableArray *rules = [NSMutableArray array];
	
	NSUInteger length = [itemset count];
	NSMutableArray *mask = [NSMutableArray array];
	for (NSUInteger i=0; i<length; i++)
		[mask addObject:[NSNumber numberWithBool:NO]];
	
	NSMutableDictionary *supportCache = [NSMutableDictionary dictionary];
	
	while ([NNApriori nextMask:mask]) 
	{
		// generate head and body 
		NSMutableArray *body = [NSMutableArray array];
		NSMutableArray *head = [NSMutableArray array];
		
		for (NSUInteger i=0; i<[mask count]; i++) 
		{
			if ([[mask objectAtIndex:i] boolValue]) 
				[body addObject:[itemset objectAtIndex:i]];
			else
				[head addObject:[itemset objectAtIndex:i]];
		}
		
		// handle special cases, i.e. empty head or emtpy body
		if ([body count] == 0 || [head count] == 0) 
			continue;
		
		// calculate confidence of this would-be rule - use cached support values
		NSNumber *itemsetSupport = [supportCache objectForKey:itemset];
		if (itemsetSupport == nil)
		{
			NSUInteger iss = [NNApriori support:itemset];
			itemsetSupport = [NSNumber numberWithInt:iss];
			[supportCache setObject:itemsetSupport forKey:itemset];
		}
		
		NSNumber *bodySupport = [supportCache objectForKey:body];
		if (bodySupport == nil)
		{
			NSUInteger bs = [NNApriori support:body];
			bodySupport = [NSNumber numberWithInt:bs];
			[supportCache setObject:bodySupport forKey:body];
		}
		
		CGFloat confidence = [itemsetSupport floatValue]  / [bodySupport floatValue];
		if (confidence >= minConfidence) 
		{
			// generate rule
			NNAssociationRule *rule = [NNAssociationRule ruleWithContent:body head:head];
			[rule setConfidence:confidence];
			[rules addObject:rule];
		}
	}
	return rules;
}

/**
 * Returns the support of the specified itemset
 */
+ (NSUInteger)support:(NSArray*)itemset
{
	return [[[NNTagging tagging] taggedObjectsForTags:[[NNTags sharedTags] tagsForNames:itemset]] count];
}

/**
 * Creates the next ('bit'-)mask, that is an array of boolean values,
 * by modifying the specified array
 */
+ (BOOL)nextMask:(NSMutableArray*)mask
{
	NSUInteger i;
	for (i=0; (i<[mask count] && [[mask objectAtIndex:i] boolValue]); i++)
		[mask replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:NO]];
	
	if (i < [mask count]) 
	{
		[mask replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:YES]];
		return YES;
	}
	
	return NO;
}

@end
