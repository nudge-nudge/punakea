//
//  NSBezierPathCategory.h
//  punakea
//
//  Created by Daniel on 14.07.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSBezierPath (CocoaDevCategory)

+ (NSBezierPath *)bezierPathWithJaggedOvalInRect:(NSRect)r spacing:(float)spacing;
+ (NSBezierPath *)bezierPathWithJaggedPillInRect:(NSRect)r spacing:(float)spacing;
+ (NSBezierPath*)bezierPathWithRoundRectInRect:(NSRect)aRect radius:(float)radius;
+ (NSBezierPath *)bezierPathWithTriangleInRect:(NSRect)r edge:(NSRectEdge)edge;

@end
