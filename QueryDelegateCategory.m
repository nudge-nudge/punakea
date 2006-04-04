//
//  QueryDelegateCategory.m
//  punakea
//
//  Created by Daniel on 04.04.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "QueryDelegateCategory.h"


@implementation Controller (QueryDelegateCategory)

- (id)metadataQuery:(NSMetadataQuery *)query replacementValueForAttribute:(NSString *)attrName value:(id)attrValue {
    if ([attrName isEqualToString:(id)kMDItemFSSize]) {
        int fsSize = [attrValue intValue];
        // Here is a special case for small files
        if (fsSize == 0) {
            return NSLocalizedString(@"0 Byte Files", @"File size, for empty files and directories");
        }
        const int cutOff = 1024;
        
        if (fsSize < cutOff) {
            return NSLocalizedString(@"< 1 KB Files", @"File size, for items that are less than 1 kilobyte");
        }
        
        // Figure out how many kb, mb, etc, that we have
        int numK = fsSize / 1024;
        if (numK < cutOff) {
            return [NSString stringWithFormat:NSLocalizedString(@"%d KB Files", @"File size, expressed in kilobytes"), numK];
        }
        
        int numMB = numK / 1024;
        if (numMB < cutOff) {
            return [NSString stringWithFormat:NSLocalizedString(@"%d MB Files", @"File size, expressed in megabytes"), numMB];
        }
        
        return NSLocalizedString(@"Huge files", @"File size, for really large files");
    } else if ((attrValue == nil) || (attrValue == [NSNull null])) {
        // We don't want to display <null> for the user, so, depending on the category, display something better
        if ([attrName isEqualToString:(id)kMDItemKind]) {
            return NSLocalizedString(@"Other", @"Kind to display for unknown file types");
        } else {
            return NSLocalizedString(@"Unknown", @"Kind to display for other unknown values"); 
        }
    } else {
        return attrValue;
    }
    
}

@end
