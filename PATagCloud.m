#import "PATagCloud.h"

@interface PATagCloud (PrivateAPI)

- (void)drawBackground:(NSRect)rect;
- (void)drawTags:(NSRect)rect;
- (NSRect)nextRectFor:(PATag*)tag inMainRect:(NSRect)rect withAttributes:(NSDictionary*)attribs;

@end

@implementation PATagCloud

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		activeTag = [[PATag alloc] init];
		rectTags = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)awakeFromNib
{
	[relatedTagsController addObserver:self
							forKeyPath:@"arrangedObjects"
							   options:0
							   context:NULL];
}

- (void)dealloc
{
	[activeTag release];
	[rectTags release];
	[super dealloc];
}

- (PATag*)activeTag
{
	return activeTag;
}

- (void)setActiveTag:(PATag*)aTag
{
	[activeTag release];
	[aTag retain];
	activeTag = aTag;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object 
                        change:(NSDictionary *)change
                       context:(void *)context
{
	if ([keyPath isEqual:@"arrangedObjects"]) 
		[self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)rect
{	
	//if there are registered trackingRects, remove them before redrawing
	NSEnumerator *e = [rectTags objectEnumerator];
	NSTrackingRectTag rectTag;
	
	while (rectTag = [[e nextObject] intValue])
		[self removeTrackingRect:rectTag];
	
	//TODO externalize values
	pointForTagRect = NSMakePoint(10,rect.size.height-35);
	
	[self drawBackground:rect];
	[self drawTags:rect];
}

- (void)drawBackground:(NSRect)rect
{
	NSRect bounds = [self bounds];
	[[NSColor whiteColor] set];
	[NSBezierPath fillRect:bounds];
}

- (void)drawTags:(NSRect)rect
{
	NSEnumerator *e = [[relatedTagsController arrangedObjects] objectEnumerator];
	
	PATag *tag;
	
	while (tag = [e nextObject])
	{
		NSDictionary *attributes = [tag viewAttributes];
		NSRect tagRect = [self nextRectFor:tag inMainRect:rect withAttributes:attributes];
		[tag drawInRect:tagRect withAttributes:attributes];
		
		//add tracking - keep track of the trackingRects so that the can be removed on redraw
		NSTrackingRectTag rectTag = [self addTrackingRect:tagRect owner:self userData:tag assumeInside:NO];
		[rectTags addObject:[NSNumber numberWithInt:rectTag]];
	}
}

- (NSRect)nextRectFor:(PATag*)tag inMainRect:(NSRect)rect withAttributes:(NSDictionary*)attribs
{
	//TODO externalize spacing and padding and ...
	int height = 35;
	int spacing = 10;
	int padding = 10;
	
	//first get the tag size for the tag to draw
	NSSize tagSize = [tag sizeWithAttributes:attribs];
	
	int xValue = pointForTagRect.x + tagSize.width + padding;
	
	if (xValue > rect.size.width)
	{
		pointForTagRect = NSMakePoint(padding,pointForTagRect.y-height);
	}
		
	NSRect tagRect =  NSMakeRect(pointForTagRect.x,pointForTagRect.y,tagSize.width,tagSize.height);
	
	//then calc the point for the next tag 
	pointForTagRect = NSMakePoint(pointForTagRect.x + tagSize.width + spacing,pointForTagRect.y);
	
	return tagRect;
}

//EVENT HANDLING
- (void)mouseEntered:(NSEvent*)event
{
	NSLog(@"entered %@",[event userData]);
	[self setActiveTag:[event userData]];
	[[self activeTag] setHighlight:YES];
	[self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent*)event
{
	NSLog(@"left %@",activeTag);
	[[self activeTag] setHighlight:NO];
	[self setActiveTag:NULL];
	[self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent*)event
{
	NSLog(@"clicked tag %@",activeTag);
	
	if (activeTag != NULL)
	{
		[selectedTagsController addObject:activeTag];
		[activeTag incrementClickCount];
	}
}

@end
