//
//  PASmartFolder.h
//  punakea
//
//  Created by Daniel on 30.03.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NNTagging/NNTag.h"


@interface PASmartFolder : NSObject {

}

+ (NSString *)smartFolderFilenameForTag:(NNTag *)tag;

@end
