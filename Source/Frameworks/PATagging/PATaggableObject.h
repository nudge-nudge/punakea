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
 
 important: take care to save the files to backup storage on dealloc in all subclasses!
 
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
		
	NSWindow				*errorWindow;
}

- (NSMutableSet*)tags;

/** 
should be used internally only (for example to
implement copying), as it does not save the new
tags to the backup storage

if you want to do that, please call initiateSave 
afterwards
*/
- (void)setTags:(NSMutableSet*)someTags;

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

+ (id)replaceMetadataValue:(id)attrValue forAttribute:(NSString *)attrName;

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

/**
will be called on renaming
 must be implemented in subclass
 @param newName new name for taggable object
 @param window error window
 @return success as bool
 */
- (void)renameTo:(NSString*)newName errorWindow:(NSWindow*)window;

/**
checks if new name for object is valid
 for example:
 PAFile needs to check if the filename is free in the directory
 
 must be implemented by subclass!
 @param newName proposed name
 @return YES if valid, else NO
 */
- (BOOL)validateNewName:(NSString*)newName;

- (id)replaceMetadataValue:(id)attrValue forAttribute:(NSString *)attrName;


@end