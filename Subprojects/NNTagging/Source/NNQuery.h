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
#import "NNTag.h"
#import "NNTagStoreManager.h"

#import "NNQueryBundle.h"
#import "NNQueryFilter.h"
#import "NNSelectedTags.h"
#import "NSFileManager+Extensions.h"

@class NNFile;
@class NNTagStoreManager;
@class NNTagToFileWriter;

/** Posted when the receiver begins with the initial result-gathering phase of the query. */
extern NSString * const NNQueryDidStartGatheringNotification;

/** Posted when new results have been found */
extern NSString * const NNQueryGatheringProgressNotification;

/** Posted when the receiver’s results have changed during the live-update phase of the query. */
extern NSString * const NNQueryDidUpdateNotification;

/** Posted when the receiver has finished with the initial result-gathering phase of the query. */
extern NSString * const NNQueryDidFinishGatheringNotification;

/** Posted when the query is reset - needed when results are emptied */
extern NSString * const NNQueryDidResetNotification;

/** Posted when the receiver's grouping attributes have changed. */
//extern NSString * const NNQueryGroupingAttributesDidChange;


/**
NNQuery is mainly a wrapper around the NSMetadataQuery class, and shares a lot of its API. 
 There are additional methods for manipulating the search, as NNQuery uses NNTag instances instead of 
 directly setting the NSPredicate.
  */
@interface NNQuery : NSObject
{
	MDQueryRef				mdquery;
	MDQueryBatchingParams	batchingParams;
		
	NSArray					*valueListAttrs; // fetching the needed attributes in the query is a lot faster
	
	NNTagToFileWriter		*tagToFileWriter;
	NSString				*tagsSpotlightMetadataField;
	
	NSDictionary			*simpleGrouping;
	
	NNSelectedTags			*tags;
		
	NSMutableDictionary		*bundles;
	NSArray					*bundlingAttributes;
	
	NSArray					*sortDescriptors;
	
	NSMutableDictionary		*filterDict;
	NSMutableArray			*filters;
	
	NSDate					*startDate;
	NSDate					*endDate;
	
	NSMutableArray			*plainResults;
	NSMutableArray			*flatPlainResults;
	NSMutableArray			*filteredResults;
	NSMutableArray			*flatFilteredResults;
	
	NSWindow				*errorWindow;
	
	// query states
	BOOL					started;
	BOOL					stopped;
	BOOL					gathering;
	
	NSString				*metadataCacheFolder;
}

/**
 Executes a synchronous query for the query string
 that will return the results immediately.
 @param queryString Query string to execute
 @return TaggableObjects for query string
 */
- (NSArray*)executeSynchronousQueryForString:(NSString*)queryString;

/**
 Executes a synchronous query that will return the results
 immediately.
  
 @return TaggableObjects for selected tags
 */
- (NSArray*)executeSynchronousQuery;

/**
 Executes a synchronous query that will return the bundled
 results immediately.
 @param attr Bundling attribute, i.e. kMDItemContentTypeTree
 @return Bundles that contain taggableObjects for selected tags
 */
- (NSArray *)executeSynchronousQueryWithBundlingAttribute:(NSString *)attr;

/**
@return New query - use setTags: to set tags for searching
 */
- (id)init;

/**
Designated initializer - call this one if you want to set the selected tags 
 right away.
 @param otherTags Tags to search for
 @return NNQuery ready to search for otherTags
 */
- (id)initWithTags:(NNSelectedTags*)otherTags;

/**
@return Tags the query is currently prepared to search for
 */
- (NNSelectedTags*)tags;

/**
@param otherTags Tags to search for
 */
- (void)setTags:(NNSelectedTags*)otherTags;

//wrapper methods
/**
Starts the query
 @return YES when succesful, NO otherwise
 */
- (BOOL)startQuery;

/**
Stops the query
 */
- (void)stopQuery;

/**
Temporarily stops the query from gathering results - 
 use this if you e.g. want to display intermediate results.
 */
- (void)disableUpdates;

/**
Reenables result gathering - use this after disableUpdates.
 */
- (void)enableUpdates;

/**
@return YES if query is started, NO otherwise
 */
- (BOOL)isStarted;

/**
@return YES if the query is stopped, NO otherwise
 */
- (BOOL)isStopped;

/**
This returns YES if the query is started and updating was not
 disabled.
@return YES if query is gathering results, NO otherwise
 */
- (BOOL)isGathering;

/**
@return Number of results currently found
 */
- (NSUInteger)resultCount;

/**
@param idx Index of the result to return
 @return Result at position idx
 */
- (id)resultAtIndex:(NSUInteger)idx;

// query extension
/**
@return Results that may contain a hierarchical tree of bundles
 or a flat list of items. This depends on the current bundling
 attributes.
 */
- (NSArray *)results;

/**
@return Results as flat array
 */
- (NSArray *)flatResults;

/**
 @return Results as flat unfiltered array.
 */
- (NSMutableArray *)flatPlainResults;

/**
@return Bundling attributes as array
*/
- (NSArray *)bundlingAttributes;

/**
Sets new bundling attributes
@param attributes The new attributes to use
*/
- (void)setBundlingAttributes:(NSArray*)attributes;

/**
@return Sort descriptors
*/
- (NSArray *)sortDescriptors;

/**
@param someSortDescriptors The new sortDescriptors to use
*/
- (void)setSortDescriptors:(NSArray*)someSortDescriptors;

/**
@return Array of NNQueryFilters
 */
- (NSArray*)filters;

/**
@param someFilters Filters to use when executing the query
 */
- (void)setFilters:(NSMutableArray*)someFilters;

/**
Adds a filter to the query
 @param filter Filter to add
 */
- (void)addFilter:(NNQueryFilter*)filter;

/**
Adds multiple filters to the query
 @param someFilters Filters to add
 */
- (void)addFilters:(NSArray*)someFilters;

/**
Removes a filter from the query
 @param filter Filter to remove
 */
- (void)removeFilter:(NNQueryFilter*)filter;

/**
Removes all active query filters
 */
- (void)removeAllFilters;

/**
 @return startDate
 */
- (NSDate*)startDate;

/**
 If a startDate is set, tagged objects will only
 be retrieved if they have been tagged AFTER
 the given date
 
 @param date	Start date of tagged objects to return
 */
- (void)setStartDate:(NSDate*)date;

/**
 @return endDate
 */
- (NSDate*)endDate;

/**
 If a endDate is set, tagged objects will only
 be retrieved if they have been tagged BEFORE
 the given date
 
 @param date	End date of tagged objects to return
 */
- (void)setEndDate:(NSDate*)date;

/**
 TODO daniel
 
Applies new filter. may be set at any time even if the query is currently active.
 This has nothing to do with the filter methods above. filterResults: will filter gathered results,
 whereas the NNQueryFilters will constrain the query directly.
 @param flag If YES filter is applied
 @param filterValues Array of values to use for the filter, e.g. "DOCUMENTS" or "PDF"
 @param attribute DEPRECATED - currently supposed to be "kMDItemContentTypeTree"
 @param newAttributes DEPRECATED
 */
-   (void)filterResults:(BOOL)flag
			usingValues:(NSArray *)filterValues
   forBundlingAttribute:(NSString *)attribute
  newBundlingAttributes:(NSArray *)newAttributes;

/**
Returns YES if there are results for the given filter.
 @param filterValues Array of values to use for the filter, e.g. "DOCUMENTS" or "PDF"
 @param attribute Attribute to use, e.g. "kMDItemContentTypeTree"
 @return YES if there are results, NO otherwise
 */
- (BOOL)hasResultsUsingFilterWithValues:(NSArray *)filterValues
                   forBundlingAttribute:(NSArray *)attribute;

/**
@return YES if there's currently a filter
 */
- (BOOL)hasFilter;


@end