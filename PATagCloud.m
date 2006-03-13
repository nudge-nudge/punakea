#import "PATagCloud.h"

@interface PATagCloud (PrivateAPI)

- (void)drawBackground:(NSRect)rect;
- (void)drawTags:(NSRect)rect;
- (void)drawTag:(PATag*)tag inMainRect:(NSRect)rect;
- (NSRect)nextRectFor:(PATag*)tag inMainRect:(NSRect)rect withAttributes:(NSDictionary*)attribs;

@end


@implementation PATagCloud

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		//init here ...
	}
	return self;
}

- (void)drawRect:(NSRect)rect
{	
	//TODO externalize values
	pointForTagRect = NSMakePoint(10,rect.size.height-30);
	
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
	NSEnumerator *e = [[controller arrangedObjects] objectEnumerator];
	
	PATag *tag;
	
	while (tag = [e nextObject]) 
		[self drawTag:tag inMainRect:rect];		
}

- (void)drawTag:(PATag*)tag inMainRect:(NSRect)rect
{
	NSMutableDictionary *attribs = [[NSMutableDictionary alloc] init];
	
	NSColor *c = [NSColor redColor];
	NSFont *fnt = [NSFont fontWithName:@"Geneva" size:24];
	
	[attribs setObject:c forKey:NSForegroundColorAttributeName];
	[attribs setObject:fnt forKey:NSFontAttributeName];
		
	NSRect tagRect = [self nextRectFor:tag inMainRect:rect withAttributes:attribs];
	
	[[tag name] drawInRect:tagRect withAttributes:attribs];
	
	[attribs release];
}

- (NSRect)nextRectFor:(PATag*)tag inMainRect:(NSRect)rect withAttributes:(NSDictionary*)attribs
{
	//TODO externalize spacing and padding and ...
	int height = 25;
	int spacing = 10;
	int padding = 10;
	
	//first get the tagRect for the current tag
	NSSize tagSize = [[tag name] sizeWithAttributes:attribs];
	
	int xValue = pointForTagRect.x + tagSize.width + padding;
	
	if (xValue > rect.size.width)
		pointForTagRect = NSMakePoint(padding,pointForTagRect.y-height);
	
	NSRect tagRect = NSMakeRect(pointForTagRect.x,pointForTagRect.y,tagSize.width,tagSize.height);
	
	//then calc the point for the next tag 
	NSPoint newPoint = NSMakePoint(pointForTagRect.x + tagSize.width + spacing,pointForTagRect.y);
	pointForTagRect = newPoint;
	
	return tagRect;
}

@end
