//
//  PAMetaMatrix.h
//  punakea
//
//  Created by Daniel on 30.03.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PAMetaMatrixGroupCell.h"
#import "PAMetaMatrixItemCell.h"


@interface PAMetaMatrixView : NSMatrix {

	id delegate;
	NSMetadataQuery *query;

}

- (id)delegate;
- (void)setDelegate:(id)newDelegate;

@end


@interface NSObject (PAMetaMatrixDelegate)

@end


@interface NSObject (PAMetaMatrixDataSource)

@end