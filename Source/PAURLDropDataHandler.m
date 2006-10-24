//
//  PAURLDropDataHandler.m
//  punakea
//
//  Created by Johannes Hoffart on 10.09.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAURLDropDataHandler.h"

static OSType kDragWeblocType = 'drag';
static OSType kURLWeblocType = 'url ';
static OSType kTEXTWeblocType = 'TEXT';
static OSType kURLNWeblocType = 'urln';

// =================================================================================
// types used inside a webloc file

// type  'TEXT' - just plain text "http://www.cocoatech.com"
// type  'url ' - just plain text "http://www.cocoatech.com"
// type  'urln' - plain text (url name)
// type  'drag' - WLDragMapHeaderStruct with n WLDragMapEntries

#pragma options align=mac68k

typedef struct WLDragMapHeaderStruct
{
    long mapVersion;  // always 1
    long unused1;     // always 0
    long unused2;     // always 0
    short unused;
    short numEntries;   // number of repeating WLDragMapEntries
} WLDragMapHeaderStruct;

typedef struct WLDragMapEntryStruct
{
    OSType type;
    short unused;  // always 0
    ResID resID;   // always 128 or 256?
    long unused1;   // always 0
    long unused2;   // always 0
} WLDragMapEntryStruct;

#pragma options align=reset

// =================================================================================

@interface WLDragMapEntry : NSObject
{
    OSType _type;
    ResID _resID;
}

+ (id)entryWithType:(OSType)type resID:(int)resID;

- (OSType)type;
- (ResID)resID;
- (NSData*)entryData;

@end

// ==================================================================================

@interface PAURLDropDataHandler (PrivateAPI)

- (NSData*)dragDataWithEntries:(NSArray*)entries;

@end

@implementation PAURLDropDataHandler

/**
data is NSDictionary with keys:
 "" : URL
 "title" : title
*/
- (PAFile*)fileDropData:(id)data
{
	NSString *url = [data objectForKey:@""];
	NSString *filename = [[data objectForKey:@"title"] stringByAppendingString:@".webloc"];
	NSString *filePath = [self destinationForNewFile:filename];
	
	NDResourceFork *resource = [[NDResourceFork alloc] initForWritingAtPath:filePath];
	NSMutableArray *entryArray = [NSMutableArray array];
	NSData *resouceData;
	
	// add the 'TEXT' resource
	resouceData = [NSData dataWithBytes:[url UTF8String] length:strlen([url UTF8String])];
	[resource addData:resouceData type:kTEXTWeblocType Id:256 name:filename];
	[entryArray addObject:[WLDragMapEntry entryWithType:kTEXTWeblocType resID:256]];
	
	// add the 'url ' resource
	[resource addData:resouceData type:kURLWeblocType Id:256 name:filename];
	[entryArray addObject:[WLDragMapEntry entryWithType:kURLWeblocType resID:256]];
	
	// add the 'urln' resource
	resouceData = [NSData dataWithBytes:[filename UTF8String] length:strlen([filename UTF8String])];
	[resource addData:resouceData type:kURLNWeblocType Id:256 name:filename];
	[entryArray addObject:[WLDragMapEntry entryWithType:kURLNWeblocType resID:256]];
	
	// add the 'drag' resource
	[resource addData:[self dragDataWithEntries:entryArray] type:kDragWeblocType Id:128 name:filename];
	[resource release];
	
	return [PAFile fileWithPath:filePath];
}

- (NSDragOperation)performedDragOperation
{
		return NSDragOperationCopy;
}

#pragma mark helpers
- (NSData*)dragDataWithEntries:(NSArray*)entries
{
    NSMutableData *result;
    WLDragMapHeaderStruct header;
    NSEnumerator *enumerator = [entries objectEnumerator];
    WLDragMapEntry *entry;
    
    // zero the structure
    memset(&header, 0, sizeof(WLDragMapHeaderStruct));
	
    header.mapVersion = 1;
    header.numEntries = [entries count];
	
    result = [NSMutableData dataWithBytes:&header length:sizeof(WLDragMapHeaderStruct)];
	
    while (entry = [enumerator nextObject])
        [result appendData:[entry entryData]];
	
    return result;
}

@end

// =================================================================================

@implementation WLDragMapEntry

- (id)initWithType:(OSType)type resID:(int)resID;
{
    self = [super init];
	
    _type = type;
    _resID = resID;
	
    return self;
}

+ (id)entryWithType:(OSType)type resID:(int)resID;
{
    WLDragMapEntry* result = [[WLDragMapEntry alloc] initWithType:type resID:resID];
	
    return [result autorelease];
}

- (OSType)type;
{
    return _type;
}

- (ResID)resID;
{
    return _resID;
}

- (NSData*)entryData;
{
    WLDragMapEntryStruct result;
	
    // zero the structure
    memset(&result, 0, sizeof(result));
    
    result.type = _type;
    result.resID = _resID;
	
    return [NSData dataWithBytes:&result length:sizeof(result)];
}

@end
