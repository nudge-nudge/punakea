//
//  PATaggableObject.h
//  punakea
//
//  Created by Johannes Hoffart on 19.12.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PATag.h"
#import "PATags.h"

extern NSString * const PATaggableObjectUpdate;

/**
abstract class representing a taggable object (normally a file
 but can be anything really)
 
 tags must be loaded by subclass!
 */
@interface PATaggableObject : NSObject <NSCopying> {
	
	NSMutableSet			*tags;
	PATags					*globalTags;
	
	int						retryCount;
	
	NSString				*displayName;
	NSString				*contentType;
	NSString				*contentTypeIdentifier;
	NSArray					*contentTypeTree;
	NSDate					*lastUsedDate;

	NSNotificationCenter	*nc;
	
	NSDictionary			*simpleGrouping;
}

- (NSSet*)tags;
- (void)setTags:(NSSet*)someTags;

- (int)retryCount;
- (void)incrementRetryCount;
- (void)setRetryCount:(int)i;

- (NSString *)displayName;
- (void)setDisplayName:(NSString *)aDisplayName;
- (NSString *)contentType;
- (void)setContentType:(NSString *)aContentType;
- (NSString *)contentTypeIdentifier;
- (void)setContentTypeIdentifier:(NSString *)aContentTypeIdentifier;
- (NSArray *)contentTypeTree;
- (void)setContentTypeTree:(NSArray *)aContentTypeTree;
- (NSDate *)lastUsedDate;
- (void)setLastUsedDate:(NSDate *)aDate;

- (void)addTag:(PATag*)tag;
- (void)addTags:(NSArray*)someTags;
- (void)removeTag:(PATag*)tag;
- (void)removeTags:(NSArray*)someTags;
- (void)removeAllTags;

/**
call this if you want to save to harddisk,
 don't call saveTags directly
 */
- (void)initiateSave;

/**
will be called when files are scheduled for file managing,
 abstract method does nothing, subclass may implement on demand
  - only called if pref is set
 */
- (void)handleFileManagement;

/**
must be implemented by subclass,
 save tags to backing storage
 @return success or failure
 */
- (BOOL)saveTags;

- (id)replaceMetadataValue:(id)attrValue forAttribute:(NSString *)attrName;


@end