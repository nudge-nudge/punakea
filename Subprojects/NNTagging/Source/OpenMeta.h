//
//  OpenMeta.h
//  OpenMeta
//
//  Created by Tom Andersen on 17/07/08.
//
/*
Copyright (c) 2009 ironic software

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
*/

#import <Cocoa/Cocoa.h>

/*
        Open Meta - why duplicate attributes that are already defined?
        
        To answer this, look at an example. kMDItemKeywords:
        
        When a file with keywords embedded in it is created or lands on the computer, say for example a PDF file, Spotlight
        will import it. The keywords will be stored under kMDItemKeywords in the Spotlight DB. 
        
        Now a user wants to set keywords (ie tags) on a file - any file on their computer - whether or not
        the file type supports keywords or not. If Open Meta used kMDItemKeywords to store these - it will work pretty well,
        until the user stored their own tags, on that PDF file that already had embedded keywords. Then all sorts of problems happen:
        1) The existing keywords are hidden from the user, as keywords set on the xattr will override the ones set in the meta data. 
        2) These hidden keywords will come back when the file is viewed with Preview, or Acrobat, etc. 
        3) If the keywords on the the file are changed inside Preview, then these changes will not show up in spotlight
        
        There are two solutions to this sort of problem. 
        
        One is to edit the 'actual keywords' inside the PDF. This solution quickly gets
        complicated, as for each file type there may be none (eg: text file), one (eg:PDF), several (eg: jpeg, word?) 
        places to store keywords, and the software to read and write keywords into all supported file types 
        quickly grows to be unmanagable. The solution for text and other non keywordable files 
        is to write the tags somewhere else (eg sidecar files). 
        
        The other solution is the tact taken by Open Meta. 
        Keywords are written to their own tag, which is indexed by Spotlight, (kMDItemOMUserTags). 
        These tags are independent of kMDItemkeywords. 
        They can be written in the exact same very simple manner to each and every file on the file system. 
        They do not hide the keywords set on the file. 
        Since they are stored in xattrs, they can easily be included or excluded from a file, when 
        that file is for instance shipped off to a third party. 
        This is useful in order to keep metadata 'in house'. BUT - the data set by OpenMeta is not 'in the file' the same 
        way that tags set on a jpeg are 'in' the EXIF portion of the file when bridge does it. 
        The Open Meta tags follow the file around on the OS - through backups, copies and moves. 
        
		Other keys
		----------------
		 I used to consider it 'wrong' to be able to override kMDItem* stuff with OpenMeta, and it is for tags. Tags though are a special case,
		 in that there could be for instance 6 keywords (relevant - ish) set on a PDF, and you want to add the open meta tag 'special' to it. You don't want to 
		 lose the 6 keywords do you? There are also lots of images from image houses that have a lot of keyword 'noise' in them that you might not want
		 cluttering up your tags that you have set. i have found png files with 50 keywords set. html can also be bad for this. So users want the ability to only look at tags that they have set,
		 or a combination of keywords and tags.
		 BUT - look at ratings - ratings are just one number - it is likely that you don't want to as a user, have to think about 2 different places ratings 
		 could be stored, (like tags vs keywords), but would rather have just the one concept of 'rating'. It is also ok, even deisrable, to be able to override the rating
		 on a file. So ratings _should_ use kMDItemStarRating.
		 Also look at 'less used' keys - like camera (kMDItemAcquisitionMake and  kMDItemAcquisitionModel) - although they will be set on perhaps thousands of photos in 
		 what if you run into a PDF that is a picture taken with a camera, and you want to tag that? openmeta will allow you to to tag it with kMDItemAcquisitionMake and kMDItemAcquisitionModel
		 so that searches for camera make an model do not have to 'know about openmeta' to work. 
		 Plus it's always good to keep the number of keys down.
      
        What about namespaces?
        ----------------------
        Open Meta is a clean simple way to set user entered searchable metadata on any file on Mac OS X. 
        Concepts like namespaces are not encouraged, as most users have no idea what a namespace is. The tradeoff is a 
        small amount of _understandable_ ambiguity - searching for Tags:apple (i.e. kMDItemOMUserTags == "apple"cd) will find
        all files having to do with both the fruit one can eat, and the company that makes computers. Users expect this. 
        With namespaces an improperly constructed query will usually result in 'no matches'. 
*/


/*
    Note on Backup.
	
	Whenever you set an item with kMDItemOM* as the key, openmeta will make sure that there is a backup made of the tags, etc, that 
	you have set on the file. The backups go into the folder ~/Library/Application Support/OpenMeta/backups.noindex/2009 etc. The backups are
	one file per item, and are on a month by month basis. This may be all the backup you need, as time machine will back these up.
	The .noindex suffix on the backup folder stops Spotlight from indexing the files.
	
    Note on Backup - "Time Machine", etc.
    When you set an xattr on a file, the modification date on the file is NOT changed, 
    but something called the status change time - does change.
    Time Machine, however, will only back up on modified time changes - i.e. it only looks at st_mtimespec, ignoring st_ctimespec. 
    This is a deliberate decision on TimeMachine's part.
    So if you want your xattrs backed up - you need to set the modifcation date on the file to a newer date - utimes() is the call for this. 
    It may be that you do not want to change the file modification date for each OpenMeta item that you write. If you do change the modification date, 
    it may make sense to not change it 'by much' - thus preserving most of the 
    meaning of the modification date, while still allowing TimeMachine to back the file up.
*/


// OpenMeta: Open metadata format for OS X. Data is stored in xattr.
// Some items are reflected in the Spotlight Database, others not. 
// ---------------------
// This system allows someone to set metadata on a file, and have that metadata searchable in spotlight.
// Several open meta keys are defined: See the schema.xml file in the OpenMeta spotlight plugin for the complete list.
// 
// User Entered Tags: Tags that users have added for workflow and organizational reasons. 
//
// Bookmarks: URLs associated with a document
// 
// Workflow: people, companies, etc that are in the workflow for this document
//
// Projects: Projects that this file is relevant to

// on success return nil error
// If setting/getting user tags failed we return a negative error code for one of our errors, or the error code from the underlying api (setxattr)
// If there is errno set after a call we return that. errno codes seem to be positive numbers
// We use NSError, and you can pass in nil if you are not interested in an error.
#define OM_ParamError (-1)
#define OM_NoDataFromPropertyListError (-2)
#define OM_NoMDItemFoundError (-3)
#define OM_CantSetMetadataError (-4)
#define OM_MetaTooBigError (-5)
// A very common errno error code is ENOATTR - the attribute is not set on the file. - which we don't consider an error

extern NSString* const kMDItemOMUserTags;
extern NSString* const kMDItemOMUserTagTime;
extern NSString* const kMDItemOMDocumentDate;
extern NSString* const kMDItemOMBookmarks; // list of urls - bookmarks as nsarray nsstring 
extern NSString* const kMDItemOMUserTagApplication;

extern const double kMDItemOMMaxRating;

// kMDItemKeywords
@interface OpenMeta : NSObject {

}

// User tags - an array of tags as entered by the user. This is not the place to 
// store program generated gook, like GUIDs or urls, etc.
// It is not nice to erase tags that are already set (unless the user has deleted them using your UI)
// so ususally you would do a getUserTags, then merge/edit/ etc, followed by a setUserTags
// Tags - NSStrings - conceptually utf8 - any characters allowed, spaces, commas, etc.
// Case sensitive or not? Case preserving. Order of tags is not guaranteed, but it is attempted.
// setUserTags will remove duplicates from the array, using case preserving rules. 
+(NSError*)setUserTags:(NSArray*)tags path:(NSString*)path;
+(NSArray*)getUserTags:(NSString*)path error:(NSError**)error;
+(NSError*)addUserTags:(NSArray*)tags path:(NSString*)path;
+(NSError*)clearUserTags:(NSArray*)tags path:(NSString*)path;


// To change tags on groups of files: 
// You first obtain the common tags in a list of files, 
// then edit those common tags, then set the changes
// you need to pass in the original common tags when writing the new tags out, 
// so that we can be sure we are not overwriting other changes made by other users, etc 
// during the edit cycle:
// These calls are case preserving and case insensitive. So Apple and apple will both be the 'same' tag on reading
+(NSError*)setCommonUserTags:(NSArray*)paths originalCommonTags:(NSArray*)originalTags replaceWith:(NSArray*)newTags;
+(NSArray*)getCommonUserTags:(NSArray*)paths error:(NSError**)error;


// Ratings are 0 - 5 stars. Setting a rating to 0 is the same as having no rating. 
// rating is 0 - 5 floating point, so you have plenty of room. I clamp 0 - 5 on setting it.
// passing 0 to setRating removes the rating. Also I return 0 if I can't find a rating.
// Users have a hard time conceptualizing the difference between having no rating set and a rating of 0
+(NSError*)setRating:(double)rating05 path:(NSString*)path;
+(double)getRating:(NSString*)path error:(NSError**)error;

// simplest way to set metadata that will be picked up by spotlight:
// The string will be stored in the spotlight datastore. Likely you will not want 
// to set large strings with this, as it will be hard on the spotlight db.
+(NSError*)setString:(NSString*)string keyName:(NSString*)keyName path:(NSString*)path;
+(NSString*)getString:(NSString*)keyName path:(NSString*)path error:(NSError**)error;


// If you have a 'lot' (ie 200 bytes to 4k) to set as a metadata on a file, then what you want to do
// is use the setDictionaries call. You organize your data in an array of dictionaries, 
// and each dict will be put into the metadata store and NOT be indexed by spotlight. 
// In each dictionary, you optionally set one item with the key @"name" and THAT information will be stored in the spotlight DB
// Say you set keyName to 'kMDItemOMLastPrintedInfo', then there would be an xattr with the name 'kMDItemOMLastPrintedInfo' that is an array of nsdictionaries
// AND an xattr set on the file with com.apple.metadata:kMDItemOMLastPrintedInfo' which will be an array of the 'names' from the dicts. 
// the 'name' would usually be used for search purposes. Other data can be 'anything'


// for meta data in arrays: The add call weeds out duplicates 
+(NSArray*)getNSArrayMetaData:(NSString*)metaDataKey path:(NSString*)path error:(NSError**)error;
+(NSError*)setNSArrayMetaData:(NSArray*)array metaDataKey:(NSString*)metaDataKey path:(NSString*)path;
+(NSError*)addToNSArrayMetaData:(NSArray*)itemsToAdd metaDataKey:(NSString*)metaDataKey path:(NSString*)path;


// extended attributes:
// These getters and setters are to set xattr data that will be read and indexed by spotlight
// If you pass large amounts of data or objects like dictionaries that spotlght cannot index, results are undefined.
// The only things that spotlight can handle (as far as I know) are small arrays and nsstrings, nsdates, and nsnumbers 
+(id)getXAttrMetaData:(NSString*)metaDataKey path:(NSString*)path error:(NSError**)error;
+(NSError*)setXAttrMetaData:(id)plistObject metaDataKey:(NSString*)metaDataKey path:(NSString*)path;

// dictionaries:
// Spotlight can't have dictionaries in it's database.
// remember that. You can store dictionaries using getXAttrMetaDataNoSpotlightMirror, or just setXAttr


// to set data with no spotlight mirror, use this. omKey is something like kMDItemOMSomeKeyThatsNotNeededInSpotlight
+(id)getXAttrMetaDataNoSpotlightMirror:(NSString*)omKey path:(NSString*)path error:(NSError**)error;
+(NSError*)setXAttrNoSpotlightMirror:(id)plistObject omKey:(NSString*)omKey path:(NSString*)path;

// These getters and setters are to set xattr data that will be NOT read and indexed by spotlight - nor are openmeta time stamps set, nor is restore done on backup.
// The passed plist object will be converted to data as a binary plist object. (plist object is for example an nsdictionary or nsarray)
// You can pass data up to 4k (or close to that depending on how much the data takes up in binary plist format)
+(id)getXAttr:(NSString*)inKeyName path:(NSString*)path error:(NSError**)error;
+(NSError*)setXAttr:(id)plistObject forKey:(NSString*)inKeyName path:(NSString*)path;


// utils
+(NSArray*)orderedArrayWithDict:(NSDictionary*)inTags sortHint:(NSArray*)inSortedItems;

// this call makes sure that all the keys in the OpenMeta kMDItemOM group get seen by Spotlight, so that the associated strings.xml. strings.schema, etc can work.
+(void)registerUsualOMAttributes; // just call this on launch if you want to be sure. 
+(void)registerOMAttributes:(NSDictionary*)typicalAttributes forAppName:(NSString*)appName;

+(NSString*)spotlightKey:(NSString*)inKeyName;
+(NSString*)openmetaKey:(NSString*)inKeyName;
+(NSString*)openmetaTimeKey:(NSString*)inKeyName;

@end
