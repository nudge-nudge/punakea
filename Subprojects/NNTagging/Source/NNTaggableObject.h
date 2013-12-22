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
#import "NNTags.h"

extern NSString * const NNTaggableObjectUpdate;

extern NSUInteger const MANAGED_FOLDER_MAX_SUBDIR_SIZE;

/**
Abstract class representing a taggable object (normally a file
 but can be anything really)
 
 Tags must be loaded by subclass!
 */
@interface NNTaggableObject : NSObject <NSCopying> {
	
	NSMutableSet			*tags;
	NNTags					*globalTags;
	
	NSInteger						retryCount;
	
	NSString				*displayName;
	NSString				*contentType;
	NSString				*contentTypeIdentifier;
	NSArray					*contentTypeTree;
	NSDate					*lastUsedDate;

	NSNotificationCenter	*nc;
		
	NSWindow				*errorWindow;
	
	BOOL					manageFilesAutomatically;
	BOOL					manageFiles;
		
}

/**
 @return Tags on this object
 */
- (NSMutableSet*)tags;

/** 
should be used internally only (for example to
implement copying), as it does not save the new
tags to the backup storage

if you want to do that, please call initiateSave 
afterwards
*/
- (void)setTags:(NSMutableSet*)someTags;

// this can be used to keep track of failed saves
/**
 @return Current retry count
 */
- (NSInteger)retryCount;

/**
 Increments the current retry count by 1.
 */
- (void)incrementRetryCount;

/**
 @param i New retry count
 */
- (void)setRetryCount:(NSInteger)i;

/**
 @return Display name (use this to show a representation of the object in your app)
 */
- (NSString *)displayName;

/**
 @param aDisplayName New display name
 */
- (void)setDisplayName:(NSString *)aDisplayName;

/**
 See the Spotlight constants for a meaning of this.
 
 @return Content type of object
 */
- (NSString *)contentType;

/**
 @param aContentType New content type
 */
- (void)setContentType:(NSString *)aContentType;

/**
 See the Spotlight constants for a meaning of this.
 
 @return Content type identifier
 */
- (NSString *)contentTypeIdentifier;

/**
 @param aContentTypeIdentifier New content type identifier
 */
- (void)setContentTypeIdentifier:(NSString *)aContentTypeIdentifier;

/**
 See the Spotlight constants for a meaning of this.

 @return Content type tree
 */
- (NSArray *)contentTypeTree;

/**
 @param aContentTypeTree New content type tree
 */
- (void)setContentTypeTree:(NSArray *)aContentTypeTree;

/**
 @return Date when this object was last used/opened
 */
- (NSDate *)lastUsedDate;

/**
 @param aDate New last used date
 */
- (void)setLastUsedDate:(NSDate *)aDate;

/**
 Add a tag to the object - update will be saved to backing store.
 @param tag Tag to add
 */
- (void)addTag:(NNTag*)tag;

/**
 Add multiple tags to object - update will be saved to backing store.
 @param someTags Tags to add
 */
- (void)addTags:(NSArray*)someTags;

/**
 Remove a tag from object - update will be saved to backing store.
 @param tag Tag to remove
 */
- (void)removeTag:(NNTag*)tag;

/**
 Remove multiple tags from object - update will be saved to backing store.
 @param someTags Tags to remove
 */
- (void)removeTags:(NSArray*)someTags;

/**
 Removes all tags from object - update will be saved to backing store.
 */
- (void)removeAllTags;

/**
Call this if you want to save to harddisk,
 don't call saveTags directly!
 */
- (void)initiateSave;

/**
Will be called when files are scheduled for file managing,
 abstract method does nothing, subclass may implement on demand
  - only called if pref is set.
 */
- (void)handleFileManagement;

/**
Must be implemented by subclass,
 save tags to backing storage.
 
 DO NOT CALL THIS DIRECTLY - use initiateSave instead, NNTagSave will take care of 
 everything else.
 
 @return Success or failure
 */
- (BOOL)saveTags;

/**
Will be called on renaming,
 must be implemented in subclass.
 @param newName New name for taggable object
 @param window Error window
 */
- (void)renameTo:(NSString*)newName errorWindow:(NSWindow*)window;

/**
Will be called on moving to trash,
 must be implemented in subclass.
 @param flag YES trashes, NO does nothing
 @param window Error window
 */
- (void)moveToTrash:(BOOL)flag errorWindow:(NSWindow *)window;

/**
Checks if new name for object is valid
 for example:
 NNFile needs to check if the filename is free in the directory
 
 must be implemented by subclass!
 @param newName Proposed name
 @return YES if valid, else NO
 */
- (BOOL)validateNewName:(NSString*)newName;

/**
 @return YES if files should be managed
 */
- (BOOL)shouldManageFiles;

/**
 @param flag Determines if files should be managed
 */
- (void)setShouldManageFiles:(BOOL)flag;

/**
 @return YES if files are managed automatically
 */
- (BOOL)shouldManageFilesAutomatically;

/**
 @param flag Determines if files should be managed automatically
 */
- (void)setShouldManageFilesAutomatically:(BOOL)flag;

/** 
 @param attrValue	Value to replace
 @param attrName	Name of the value's attribute
 @return			Replacement value, e.g. PDF for com.adobe.pdf
 */
+ (id)replaceMetadataValue:(id)attrValue forAttribute:(NSString *)attrName;

/**
 Call this to check if metadata can be written to the object
 
 @return	YES if metadata can be written, NO otherwise
 */
- (BOOL)isWritable;

@end