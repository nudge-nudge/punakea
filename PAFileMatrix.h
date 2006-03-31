//
//  PAFileMatrix.h
//  punakea
//
//  Created by Daniel on 08.03.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#import "PAFileMatrixGroupCell.h"
//#import "PAFileMatrixItemCell.h"

@interface PAFileMatrix : NSMatrix {
	NSMetadataQuery *query;
	
	/** Key: [group value] a la "PDF Dokumente", Object: row as NSNumber */
	NSMutableDictionary *groupRowDict;
}

@end
