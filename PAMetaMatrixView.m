//
//  PAMetaMatrix.m
//  punakea
//
//  Created by Daniel on 30.03.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PAMetaMatrixView.h"


@implementation PAMetaMatrixView

#pragma mark Init + Dealloc
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self setCellClass:[NSTextFieldCell class]];
		[self renewRows:0 columns:1];

		[self setCellSize:NSMakeSize(200,20)];
		[self setAutosizesCells:YES];
    }
    return self;
}

- (void)dealloc
{
	[super dealloc];
}


#pragma mark Drawing
- (void)drawRect:(NSRect)rect
{
	// Draw background
	NSRect bounds = [self bounds];
	[[NSColor whiteColor] set];
	[NSBezierPath fillRect:bounds];
	
	[super drawRect:rect];
}


#pragma mark Notifications
- (void)queryNote:(NSNotification *)note
{	
	if ([[note name] isEqualToString:NSMetadataQueryGatheringProgressNotification] ||
		[[note name] isEqualToString:NSMetadataQueryDidUpdateNotification] ||
		[[note name] isEqualToString:NSMetadataQueryDidFinishGatheringNotification])
	{
		[self updateView];
	}
}


#pragma mark Accessors
- (id)delegate
{
    return delegate;
}
 
- (void)setDelegate:(id)newDelegate
{
    delegate = newDelegate;
}

- (NSMetadataQuery *)query
{
	return query;
}

- (void)setQuery:(NSMetadataQuery*)aQuery
{
	query = aQuery;
	NSNotificationCenter *nf = [NSNotificationCenter defaultCenter];
    [nf addObserver:self selector:@selector(queryNote:) name:nil object:query];
}

@end
