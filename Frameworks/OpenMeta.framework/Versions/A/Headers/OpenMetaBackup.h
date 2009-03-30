//
//  OpenMetaBackup.h
//  Fresh
//
//  Created by Tom Andersen on 26/01/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*
Backing up xattr:

Extended Attributes are supposed to 'not dissapear' they are connected to a file. When a user does a 'save' on a file, the default unix and cocoa apis will 
preserve all the xattrs. BUT there are applications (notably Adobe CS 4 products, like Photoshop) which do a save in such a way as to wipe out all xattrs on each file 
at each save. Not good. Also when using tools like subversion, etc where files are downloaded from the internet, xattrs can be easily lost. 

So OpenMeta makes a backup file for every edit to xattrs when using the API. 

The exact details may change in the future, the idea though is that when we go to retrieve tags for a file, if we find no tags, we check to see if there is a 
backup file we can restore from. If no backup file, then there really are no tags on the file. 

The backups are stored in the home folder of the person who made the change to the file, in ~/Library/OpenMeta/backup. This works well for most usage scenarios, 
but with network volumes or mobile volumes, it may be better to store the backups in a predetermined place on the volume.

*/

@interface OpenMetaBackup : NSObject {

}

// individual file handling:
// ---------------------------

// backup is called automatically each time you set any attribute with kOM*, so you actually don't have to call this.
+(void)backupMetadata:(NSString*)inPath;

// restore is called for you ONLY on tags and ratings. If you are using OpenMeta and not using tags or ratings, you need to call this first, in case the 
// OpenMeta data has been deleted.
+(void)restoreMetadata:(NSString*)inPath;


// Restoring all metadata 
// ---------------------------
// call this to restore all backed up meta data. Call when? On every launch is likely too much. 
// if you call to tell user when done (ie initiated from a menu command, or similar), then the process runs at full speed, putting up a dialog when done.
// it does run in a thread, though..
+(void)restoreAllMetadataOnBackgroundThread:(BOOL)tellUserWhenDone;

// shutting down OpenMeta backup and restore systems 
// ---------------------------

// call this on quit, to leave time for any restores to safely, possibly, partially finish
+(void)appIsTerminating;

// for OpenMeta.m use
+(BOOL)attributeKeyMeansBackup:(NSString*)attrName;


@end
