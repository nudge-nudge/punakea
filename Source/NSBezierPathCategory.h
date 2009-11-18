//
//  NSBezierPathCategory.h
//  punakea
//
//  Created by Daniel on 14.07.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSBezierPath (CocoaDevCategory)

+ (NSBezierPath *)bezierPathWithJaggedOvalInRect:(NSRect)r spacing:(CGFloat)spacing;
+ (NSBezierPath *)bezierPathWithJaggedPillInRect:(NSRect)r spacing:(CGFloat)spacing;
+ (NSBezierPath*)bezierPathWithRoundRectInRect:(NSRect)aRect radius:(CGFloat)radius;
+ (NSBezierPath *)bezierPathWithTriangleInRect:(NSRect)r edge:(NSRectEdge)edge;

@end
