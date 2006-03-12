#import "PATagCloud.h"

@interface PATagCloud (PrivateAPI)

- (void)drawBackground:(NSRect)rect;
- (void)drawTags:(NSRect)rect;
- (void)drawTag:(PATag*)tag inRect:(NSRect)rect;
- (NSPoint)nextPointFor:(PATag*)tag inRect:(NSRect)rect;

@end


@implementation PATagCloud

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		// Add initialization code here
	}
	return self;
}

- (void)drawRect:(NSRect)rect
{	
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
		[self drawTag:tag inRect:rect];		
}

- (void)drawTag:(PATag*)tag inRect:(NSRect)rect
{
	NSMutableDictionary *attribs = [[NSMutableDictionary alloc] init];
	
	NSColor *c = [NSColor redColor];
	NSFont *fnt = [NSFont fontWithName:@"Geneva" size:24];
	
	[attribs setObject:c forKey:NSForegroundColorAttributeName];
	[attribs setObject:fnt forKey:NSFontAttributeName];
		
	NSPoint p = [self nextPointFor:tag inRect:rect];
	
	[[tag name] drawAtPoint:p withAttributes:attribs];
	
	[attribs release];
}

- (NSPoint)nextPointFor:(PATag*)tag inRect:(NSRect)rect
{
	float width = rect.size.width;
	float height = rect.size.height;
	
	return NSMakePoint(10,10);
}

@end
