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

- (id)initWithFrame:(NSRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) {
		[self setCellClass:[NSTextFieldCell class]];
		
		[self setCellSize:NSMakeSize(200,20)];
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
	

- (void)drawRect:(NSRect)rect 
{
	[self drawBackground];
	[super drawRect:rect];
}

- (void)drawBackground
{
	NSRect bounds = [self bounds];
	[[NSColor colorWithDeviceRed:204 green:255 blue:102 alpha:1.0] set];
	[NSBezierPath fillRect:bounds];
}

//TODO hack
- (void)updateView
{
	if ([self numberOfRows] == 1)
		[self removeRow:0];
	
	int tagCount = [[selectedTagsController arrangedObjects] count];
	[self renewRows:0 columns:tagCount];
	
	NSMutableArray *cells = [[NSMutableArray alloc] init];
	
    NSEnumerator *e = [[selectedTagsController arrangedObjects] objectEnumerator];
	PATag *tag;
	
	while (tag = [e nextObject])
	{
		NSCell *cell = [[NSCell alloc] initTextCell:[tag name]];
		[cells addObject:cell];
		[cell release];
	}

	[self addRowWithCells:cells];
	[cells release];
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
