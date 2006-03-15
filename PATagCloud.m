#import "PATagCloud.h"

@interface PATagCloud (PrivateAPI)

- (void)drawBackground:(NSRect*)rect;
- (void)drawTags:(NSRect*)rect;
- (void)drawTag:(PATag*)tag inMainRect:(NSRect*)rect;
- (NSRect*)nextRectFor:(PATag*)tag inMainRect:(NSRect*)rect withAttributes:(NSDictionary*)attribs;

@end

@implementation PATagCloud

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		activeTag = [[PATag alloc] init];
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
	//TODO externalize values
	pointForTagRect = NSMakePoint(10,rect.size.height-30);
	
	NSRect *pRect = &rect;
	
	[self drawBackground:pRect];
	[self drawTags:pRect];
}

- (void)drawBackground:(NSRect*)rect
{
	NSRect bounds = [self bounds];
	[[NSColor whiteColor] set];
	[NSBezierPath fillRect:bounds];
}

- (void)drawTags:(NSRect*)rect
{
	NSEnumerator *e = [[relatedTagsController arrangedObjects] objectEnumerator];
	
	PATag *tag;
	
	while (tag = [e nextObject]) 
		[self drawTag:tag inMainRect:rect];
}

- (void)drawTag:(PATag*)tag inMainRect:(NSRect*)rect
{
	NSMutableDictionary *attribs = [[NSMutableDictionary alloc] init];
	
	NSColor *c = [NSColor redColor];
	NSFont *fnt = [NSFont fontWithName:@"Geneva" size:24];
	
	[attribs setObject:c forKey:NSForegroundColorAttributeName];
	[attribs setObject:fnt forKey:NSFontAttributeName];
		
	NSRect *tagRect = [self nextRectFor:tag inMainRect:rect withAttributes:attribs];
	
	[[tag name] drawInRect:*tagRect withAttributes:attribs];
	//add tracking
	[self addTrackingRect:*tagRect owner:self userData:tag assumeInside:NO];
	
	[attribs release];
}

- (NSRect*)nextRectFor:(PATag*)tag inMainRect:(NSRect*)rect withAttributes:(NSDictionary*)attribs
{
	//TODO externalize spacing and padding and ...
	int height = 25;
	int spacing = 10;
	int padding = 10;
	
	//first get the tagRect for the current tag
	NSSize tagSize = [[tag name] sizeWithAttributes:attribs];
	
	int xValue = pointForTagRect.x + tagSize.width + padding;
	
	if (xValue > rect->size.width)
	{
		pointForTagRect = NSMakePoint(padding,pointForTagRect.y-height);
	}
		
	NSRect newRectForTag =  NSMakeRect(pointForTagRect.x,pointForTagRect.y,tagSize.width,tagSize.height);
	NSRect *tagRect = &newRectForTag;
	
	//then calc the point for the next tag 
	pointForTagRect = NSMakePoint(pointForTagRect.x + tagSize.width + spacing,pointForTagRect.y);
	
	return tagRect;
}

//EVENT HANDLING
- (void)mouseEntered:(NSEvent*)event
{
	NSLog(@"entered %@",[event userData]);
	[self setActiveTag:[event userData]];
}

- (void)mouseExited:(NSEvent*)event
{
	NSLog(@"left %@",activeTag);
	[self setActiveTag:NULL];
}

- (void)mouseUp:(NSEvent*)event
{
	NSLog(@"clicked tag %@",activeTag);
	
	if (activeTag != NULL)
		[selectedTagsController addObject:activeTag];
}

@end
