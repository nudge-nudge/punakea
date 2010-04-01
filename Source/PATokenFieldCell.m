//
//  PATokenFieldCell.m
//  PATokenField
//
//  Created by Daniel on 27.03.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PATokenFieldCell.h"
#import "PATokenAttachmentCell.h"


@implementation PATokenFieldCell

- (id)setUpTokenAttachmentCell:(NSTokenAttachmentCell *)aCell forRepresentedObject:(id)anObj 
{
	PATokenAttachmentCell *attachmentCell = [[PATokenAttachmentCell alloc] initTextCell:[aCell stringValue]];
	
	// Get colors from delegate
	if ([[self delegate] respondsToSelector:@selector(tokenFieldCell:tokenForegroundColorForRepresentedObject:)])
	{
		NSColor *color = [[self delegate] tokenFieldCell:self tokenForegroundColorForRepresentedObject:anObj];
		[attachmentCell setTokenForegroundColor:color];
	}
	
	if ([[self delegate] respondsToSelector:@selector(tokenFieldCell:tokenBackgroundColorForRepresentedObject:)])
	{
		NSColor *color = [[self delegate] tokenFieldCell:self tokenBackgroundColorForRepresentedObject:anObj];
		[attachmentCell setTokenBackgroundColor:color];
	}
	
	[attachmentCell setRepresentedObject:anObj];
	[attachmentCell setAttachment:[aCell attachment]];
	[attachmentCell setControlSize:[self controlSize]];
	[attachmentCell setTextColor:[NSColor blackColor]];
	[attachmentCell setFont:[self font]];
	
	return [attachmentCell autorelease];
}

@end
