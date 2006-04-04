//
//  PASelectedTagsView.m
//  punakea
//
//  Created by Johannes Hoffart on 31.03.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "PASelectedTagsView.h"

@interface PASelectedTagsView (PrivateAPI)

- (void)drawBackground;
- (void)updateView;

@end

@implementation PASelectedTagsView

#pragma mark init
- (id)initWithFrame:(NSRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) {
		cellWidth = 100;
		cellHeight = 20;

		[self setCellClass:[NSTextFieldCell class]];
		
		//settings
		[self setMode:NSHighlightModeMatrix];
		[self setSelectionByRect:NO];
		
		[self setCellSize:NSMakeSize(cellWidth,cellHeight)];
		[self setAutosizesCells:YES];
    }
    return self;
}

- (void)awakeFromNib
{
	[selectedTagsController addObserver:self
							 forKeyPath:@"arrangedObjects"
								options:0
								context:NULL];
}

#pragma mark drawing
- (void)drawRect:(NSRect)rect 
{
	[super drawRect:rect];
}

//TODO no this is not the way i want it ;)
- (void)updateView
{
	//get some useful values
	int tagCount = [[selectedTagsController arrangedObjects] count];
	
	NSRect bounds = [self bounds];
	float boundsWith = bounds.size.width;
	float boundsHeight = bounds.size.height;
	
	//calc values
	int maxColumnCount = boundsWith / cellWidth;
	int maxRowCount = boundsHeight / cellHeight;
	
	//adjust matrix accordingly
	[self renewRows:maxRowCount columns:maxColumnCount];
	
	//TODO
	if (tagCount > (maxRowCount * maxColumnCount))
	{
		NSLog(@"matrix too small!! fix me!!");
	}
	else
	{
	//fill matrix
		int i;
		int j;
		int counter = 0;
		
		for (i = 0;i< maxRowCount;i++)
		{
			for (j = 0;j < maxColumnCount;j++)
			{
				PATag *tag = [[selectedTagsController arrangedObjects] objectAtIndex:counter];
				NSCell *cell = [[NSCell alloc] initTextCell:[tag name]];
				[self putCell:cell atRow:i column:j];
				[cell release];
				counter++;
			}
		}
	}
}

/**
bound to selectedTags
 */
- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object 
                        change:(NSDictionary *)change
                       context:(void *)context
{
	if ([keyPath isEqual:@"arrangedObjects"]) 
	{
		[self updateView];
	}
}
@end
