//
//  PASmartFolder.h
//  punakea
//
//  Created by Daniel on 30.03.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NNTagging/NNTag.h"
#import "NNTagging/NNTagSet.h"


@interface PASmartFolder : NSObject {

}

+ (NSString *)smartFolderFilenameForTag:(NNTag *)tag;
+ (NSString *)smartFolderFilenameForTagSet:(NNTagSet *)tagSet;

@end
