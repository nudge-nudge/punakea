//
//  PASplitView.m
//  punakea
//
//  Created by Daniel on 29.03.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PASplitView.h"


@interface PASplitView (PrivateAPI)

- (void)saveDefaults;
- (void)restoreDefaults;

- (void)splitViewDidResizeSubviews:(NSNotification *)notification;

@end



@implementation PASplitView

#pragma mark Init + Dealloc
- (void)awakeFromNib
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(frameDidChange:)
												 name:NSViewFrameDidChangeNotification
											   object:self];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(splitViewDidResizeSubviews:)
												 name:NSSplitViewDidResizeSubviewsNotification
											   object:self];
	
	if(autosaveName) [self restoreDefaults];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	if(autosaveName) [autosaveName release];
	[super dealloc];
}

#pragma mark Overridden SplitView Stuff
- (CGFloat)dividerThickness
{
	return 1.0;
}

- (void)drawDividerInRect:(NSRect)aRect
{
	[[NSColor colorWithCalibratedWhite:0.6 alpha:1.0] set];
	NSRectFill(aRect);
}

- (void)adjustSubviews
{
	// NSSplitView does not accept values given by setFrame for subviews.
	// This seems to be a bug. Thus we will handle the frames manually...
	// Currently we only support two subviews...
	
	NSArray *subviews = [self subviews];
	
	NSView *previousSubview = [subviews objectAtIndex:0];
	NSView *subview = [subviews objectAtIndex:1];
	
	NSRect previousFrame = [previousSubview frame];
	NSRect frame = [subview frame];		
	
	if([self isVertical])
	{
		frame.origin.x = previousFrame.origin.x + previousFrame.size.width + [self dividerThickness];
		frame.origin.y = previousFrame.origin.y;
		frame.size.width = [self frame].size.width - previousFrame.size.width - [self dividerThickness];
		frame.size.height = [self frame].size.height;
		
		// Check min width constraint
		if(minCoordinate2 && ![subview isHidden])
			frame.size.width = MAX(minCoordinate2, frame.size.width);
		
		// Check max width constraint
		if(maxCoordinate2 && ![subview isHidden])
			frame.size.width = MIN(maxCoordinate2, frame.size.width);
		
		[subview setFrame:frame];
		
		previousFrame.size.height = [self frame].size.height;
		previousFrame.size.width = [self frame].size.width - frame.size.width - [self dividerThickness];
		
		[previousSubview setFrame:previousFrame];
		
		// Draw divider if canDraw
		if([self canDraw])
		{
			NSRect dividerRect;
			dividerRect.origin.x = previousFrame.origin.x + previousFrame.size.width;
			dividerRect.origin.y = previousFrame.origin.y;
			dividerRect.size = NSMakeSize([self dividerThickness], [self frame].size.height);
			
			[self lockFocus];
			[self drawDividerInRect:dividerRect];
			[self unlockFocus];
		}
	}
	else 
	{	   
		if(![subview isHidden])
		{
			frame.origin.x = previousFrame.origin.x;
			frame.origin.y = previousFrame.origin.y + previousFrame.size.height + [self dividerThickness];
			frame.size.width = [self frame].size.width;
			frame.size.height = [self frame].size.height - previousFrame.size.height - [self dividerThickness];
			
			// Check min width constraint
			if(minCoordinate2 && ![subview isHidden])
				frame.size.height = MAX(minCoordinate2, frame.size.height);
			
			// Check max width constraint
			if(maxCoordinate2 && ![subview isHidden])
				frame.size.height = MIN(maxCoordinate2, frame.size.height);
			
			[subview setFrame:frame];
		}
		
		previousFrame.size.width = [self frame].size.width;
		previousFrame.size.height = [self frame].size.height - frame.size.height - [self dividerThickness];
		
		if([subview isHidden])
			previousFrame.size.height = [self frame].size.height;
		
		[previousSubview setFrame:previousFrame];
		
		// Draw divider if canDraw
		if([self canDraw])
		{
			NSRect dividerRect;
			dividerRect.origin.x = previousFrame.origin.x;
			dividerRect.origin.y = previousFrame.origin.y + previousFrame.size.height;
			dividerRect.size = NSMakeSize([self frame].size.width, [self dividerThickness]);
			
			[self lockFocus];
			[self drawDividerInRect:dividerRect];
			[self unlockFocus];
		}
	}	
	
	[previousSubview setNeedsDisplay:YES];
	[subview setNeedsDisplay:YES];
}


#pragma mark Misc
- (void)toggleSubviewAtIndex:(NSInteger)idx
{		
	if(([self isVertical] &&
		((idx == 0 && [[[self subviews] objectAtIndex:0] isHidden]) ||
		 (idx == 1 && [[[self subviews] objectAtIndex:1] isHidden]))) ||
	   (![self isVertical] && 
		((idx == 0 && [[[self subviews] objectAtIndex:0] isHidden]) ||
	     (idx == 1 && [[[self subviews] objectAtIndex:1] isHidden])))) 
	{				
		// Just restore both frames - one of these subviews was hidden before
		[[[self subviews] objectAtIndex:0] setFrame:previousFrame1];
		[[[self subviews] objectAtIndex:0] setHidden:NO];
		[[[self subviews] objectAtIndex:1] setFrame:previousFrame2];
		[[[self subviews] objectAtIndex:1] setHidden:NO];
	}
	else
	{
		// Hide subview at index 1 (more styles to support in the future)
		previousFrame1 = [[[self subviews] objectAtIndex:0] frame];
		previousFrame2 = [[[self subviews] objectAtIndex:1] frame];
		
		NSRect newFrame = previousFrame1;
		newFrame.size.height = [self frame].size.height;
		
		if(![self isVertical])
		{
			[[[self subviews] objectAtIndex:0] setFrame:newFrame];
			[[[self subviews] objectAtIndex:1] setHidden:YES];
		}
	}	
	
	[self adjustSubviews];
	
	if(autosaveName) [self saveDefaults];
}

- (void)saveDefaults
{		
	NSRect f1 = [[[self subviews] objectAtIndex:0] frame];
	NSRect f2 = [[[self subviews] objectAtIndex:1] frame];

	BOOL subview1Collapsed = [[[self subviews] objectAtIndex:0] isHidden];
	BOOL subview2Collapsed = [[[self subviews] objectAtIndex:1] isHidden];
	
	if(subview1Collapsed || subview2Collapsed)
	{
		f1 = previousFrame1;
		f2 = previousFrame2;
	}
	
	NSString *string = [NSString stringWithFormat: @"%ld %ld %ld %ld %ld %ld %ld %ld %ld %ld",
		ABS(f1.origin.x), ABS(f1.origin.y), ABS(f1.size.width), ABS(f1.size.height), subview1Collapsed,
		ABS(f2.origin.x), ABS(f2.origin.y), ABS(f2.size.width), ABS(f2.size.height), subview2Collapsed];
	
	[[NSUserDefaults standardUserDefaults] setObject:string forKey:autosaveName];
}

- (void)restoreDefaults
{	
	NSString *string = [[NSUserDefaults standardUserDefaults] objectForKey:autosaveName];
	
	if(string == nil)
		string = defaults;		// no configuration found, use defaults
	
	NSScanner* scanner = [NSScanner scannerWithString: string];
	NSRect f1, f2;
	NSInteger subview1Collapsed, subview2Collapsed;
	
	BOOL didScan =
#warning 64BIT: scanFloat: argument is pointer to float, not CGFloat
		[scanner scanFloat:&(f1.origin.x)]		&&
#warning 64BIT: scanFloat: argument is pointer to float, not CGFloat
		[scanner scanFloat:&(f1.origin.y)]		&&
#warning 64BIT: scanFloat: argument is pointer to float, not CGFloat
		[scanner scanFloat:&(f1.size.width)]	&&
#warning 64BIT: scanFloat: argument is pointer to float, not CGFloat
		[scanner scanFloat:&(f1.size.height)]	&&
#warning 64BIT: scanInt: argument is pointer to int, not NSInteger; you can use scanInteger:
		[scanner scanInt:&(subview1Collapsed)]	&&
#warning 64BIT: scanFloat: argument is pointer to float, not CGFloat
		[scanner scanFloat:&(f2.origin.x)]		&&
#warning 64BIT: scanFloat: argument is pointer to float, not CGFloat
		[scanner scanFloat:&(f2.origin.y)]		&&
#warning 64BIT: scanFloat: argument is pointer to float, not CGFloat
		[scanner scanFloat:&(f2.size.width)]	&&
#warning 64BIT: scanFloat: argument is pointer to float, not CGFloat
		[scanner scanFloat:&(f2.size.height)]	&&
#warning 64BIT: scanInt: argument is pointer to int, not NSInteger; you can use scanInteger:
		[scanner scanInt:&(subview2Collapsed)];
	
	if(didScan == NO)
	{
		// No default, so we're using the current frames
		previousFrame1 = [[[self subviews] objectAtIndex:0] frame];
		previousFrame2 = [[[self subviews] objectAtIndex:1] frame];
		return;
	}
	
	previousFrame1 = f1;
	previousFrame2 = f2;	

	[[[self subviews] objectAtIndex:0] setFrame:f1];	
	[[[self subviews] objectAtIndex:1] setFrame:f2];
	
	[self adjustSubviews];
	
	if(subview1Collapsed) [self toggleSubviewAtIndex:0];	
	if(subview2Collapsed) [self toggleSubviewAtIndex:1];
}


#pragma mark Notifications
- (void)frameDidChange:(NSNotification *)notification
{
	// Read constraint coordinates from delegate
	
	minCoordinate1 = 0.0;
	minCoordinate2 = 0.0;
	maxCoordinate1 = 0.0;
	maxCoordinate2 = 0.0;
		
	// Min constraint
	if([self delegate] &&
	   [[self delegate] respondsToSelector:@selector(splitView:constrainMinCoordinate:ofSubviewAt:)])
	{
		CGFloat min = [[self delegate] splitView:self constrainMinCoordinate:0.0 ofSubviewAt:0];
		if(min) minCoordinate1 = min;
		
		min = [[self delegate] splitView:self constrainMinCoordinate:0.0 ofSubviewAt:1];
		if(min) minCoordinate2 = min;
	}
	
	// Max constraint
	if([self delegate] &&
	   [[self delegate] respondsToSelector:@selector(splitView:constrainMinCoordinate:ofSubviewAt:)])
	{
		CGFloat max = [[self delegate] splitView:self constrainMaxCoordinate:0.0 ofSubviewAt:0];
		if(max) maxCoordinate1 = max;
		
		max = [[self delegate] splitView:self constrainMaxCoordinate:0.0 ofSubviewAt:1];
		if(max) maxCoordinate2 = max;
	}
}

- (void)splitViewDidResizeSubviews:(NSNotification *)notification
{
	if(autosaveName) [self saveDefaults];
}


#pragma mark Accessors
- (NSString *)autosaveName
{
	return autosaveName;
}

- (void)setAutosaveName:(NSString *)aName defaults:(NSString *)theDefaults
{
	if(autosaveName) [autosaveName release];
	autosaveName = [aName retain];
	
	if(defaults) [defaults release];
	defaults = [theDefaults retain];
	
	[self restoreDefaults];
}

@end
