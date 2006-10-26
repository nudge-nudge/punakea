//
//  NSBezierPathCategory.m
//  punakea
//
//  Created by Daniel on 14.07.06.
//  Copyright 2006 nudge:nudge. All rights reserved.
//

#import "NSBezierPathCategory.h"


@implementation NSBezierPath (CocoaDevCategory)

static NSPoint CubicBezierPathPointForPoints(NSPoint *p, float n) {

	// basic cubic bezier path formula where m = 1.0f - n:
	//		B(n) = m^3 * P0 + 3.0f * m^2 * n * P1 + 3.0f * m * n^2 * P2 + n^3 * P3
	float m = 1.0f - n;
	float mSquared = m * m, nSquared = n * n;
	float c0 = mSquared * m;
	float c1 = 3.0f * mSquared * n;
	float c2 = 3.0f * m * nSquared;
	float c3 = nSquared * n;
	return NSMakePoint(	c0 * p[0].x + c1 * p[1].x + c2 * p[2].x + c3 * p[3].x, 
				c0 * p[0].y + c1 * p[1].y + c2 * p[2].y + c3 * p[3].y	);
}

#define CubicBezierPathLengthApproximationMacro(c0, c1, c2, c3) x = c0 * points[0].x + c1 * points[1].x + c2 * points[2].x + c3 * points[3].x; y = c0 * points[0].y + c1 * points[1].y + c2 * points[2].y + c3 * points[3].y; length += *gaps++ = hypotf(lastX - x, y - lastY); lastX = x, lastY = y; *lengths++ = length;

// JaggedOvalCategory

+ (NSRect)_joc_validRectWithRect:(NSRect)r a:(float *)a b:(float *)b spacing:(float *)spacing {
	float aRatio = *a / NSWidth(r), bRatio = *b / NSHeight(r);
	float min_spc = fminf(*a, *b) / 4.0f;
	if (*spacing > min_spc) *spacing = min_spc;
	r = NSInsetRect(r, -*spacing, -*spacing);
	*a = NSWidth(r) * aRatio, *b = NSHeight(r) * bRatio;
	return r;
}


static float CubicBezierPathGapAdjustment(float gap, float step, int *railCount, float *mod) {

	if (gap > 0.0f) {
		gap += *mod = step - fmodf(gap, step);
		int count = (int)(gap / step);
		if (gap - (float)count * step > step / 2.0f) count++;
		*railCount += count;
	} else
		*mod = 0.0f;
	return gap / 2.0f;
}

- (void)_joc_jaggedLineToPoint:(NSPoint)p teeth:(unsigned)teeth width:(float)width buffer:(NSPoint *)buf {

	NSPoint points[4];
	unsigned elementCount = [self elementCount];
	if (elementCount) {
		[self elementAtIndex:elementCount - 1 associatedPoints:points];
		float dx = p.x - points[0].x, dy = p.y - points[0].y;
		float stepX = dx / (float)teeth, stepY = dy / (float)teeth;
		float halfStepX = stepX / 2.0f, halfStepY = stepY / 2.0f;
		float length = hypotf(dx, dy);
		float normX = dy / length * width, normY = dx / length * width;
		NSPoint *pntPtr = buf;
		int cnt_down = teeth;
		while (cnt_down--) {
			*pntPtr++ = NSMakePoint(points[0].x + normX + halfStepX, points[0].y + normY + halfStepY);
			*pntPtr++ = points[0] = NSMakePoint(points[0].x + stepX, points[0].y + stepY);
		}
		[self appendBezierPathWithPoints:buf count:teeth << 1];
	}
	
}

+ (NSBezierPath *)_joc_bezierPathWithJaggedRoundedRectInRect:(NSRect)r 
                                                            a:(float)a 
                                                            b:(float)b 
                                                 spacing:(float)spacing 
{
		
	// Here's the base method to create the jagged oval icons you see in iTunes when dragging
	// songs around. Use "bezierPathWithJaggedPillInRect:spacing:" for flat sides and
	// use "bezierPathWithJaggedOvalInRect:spacing:" for a jagged path that follows the
	// perimeter of an oval --zootbobbalu

	// set the four control points of the curve that forms the first quadrant of the ellipse
	NSPoint points[4];
	points[0].x = a, points[0].y = 0.0f;
	points[1].x = a, points[1].y = b - 0.446f * b;
	points[2].x = a - 0.446f * a, points[2].y = b;
	points[3].x = 0.0f; points[3].y = b;	
		
	// length estimates for 10 curve increments
	// gaps[] - the individual sublengths of 10 sections of the quadrant
	// lengths[] - the running length at the end of each segment 
	//				(e.g. if gaps[] = {1, 2, 3, 4...}, then lengths[] = {1, 3, 6, 10, ...})
	
	float *gaps, gapBuf[10], *lengths, lengthBuf[10];
	float length = 0.0f;
	float x, y, lastX = points[0].x, lastY = points[0].y;

	lengths = lengthBuf;
	gaps = gapBuf;
	CubicBezierPathLengthApproximationMacro(7.29e-01, 2.43e-01, 2.70e-02, 1.00e-03); 
	CubicBezierPathLengthApproximationMacro(5.12e-01, 3.84e-01, 9.60e-02, 8.00e-03); 
	CubicBezierPathLengthApproximationMacro(3.43e-01, 4.41e-01, 1.89e-01, 2.70e-02); 
	CubicBezierPathLengthApproximationMacro(2.16e-01, 4.32e-01, 2.88e-01, 6.40e-02); 
	CubicBezierPathLengthApproximationMacro(1.25e-01, 3.75e-01, 3.75e-01, 1.25e-01); 
	CubicBezierPathLengthApproximationMacro(6.40e-02, 2.88e-01, 4.32e-01, 2.16e-01); 
	CubicBezierPathLengthApproximationMacro(2.70e-02, 1.89e-01, 4.41e-01, 3.43e-01); 
	CubicBezierPathLengthApproximationMacro(8.00e-03, 9.60e-02, 3.84e-01, 5.12e-01); 
	CubicBezierPathLengthApproximationMacro(1.00e-03, 2.70e-02, 2.43e-01, 7.29e-01); 
	
	*lengths = length += *gaps = hypotf(lastX - points[3].x, points[3].y - lastY);
	lengths = lengthBuf;
	gaps = gapBuf;
	
	// pointCount is the number of jagged points in a quadrant
	int pointCount = length / spacing;
	if (pointCount < 0.0f) pointCount = 1;
		
	NSPoint lastTip = points[0];
	float step = length / (float)pointCount;
	int cnt = pointCount, gapIndex = 0;
	float c = step, lastC = 0.0f, lastLength = 0.0f, lastN = 0.0f;

	NSPoint center = NSMakePoint(NSMidX(r), NSMidY(r));
	int hRailCount = 0, vRailCount = 0;
	
	float vMod, hMod;
	float aOffset = CubicBezierPathGapAdjustment((NSWidth(r) / 2.0f - a) * 2.0f, step, &hRailCount, &hMod);
	float bOffset = CubicBezierPathGapAdjustment((NSHeight(r) / 2.0f - b) * 2.0f, step, &vRailCount, &vMod);
	if (vRailCount) vRailCount++;

	float leftOffset = center.x - aOffset, rightOffset = center.x + aOffset;
	float upperOffset = center.y + bOffset, lowerOffset = center.y - bOffset;

	int block = pointCount * 2;
	int buf_len = block * 4 + hRailCount * 2 + vRailCount * 2;

	NSPoint *buf = malloc(buf_len * sizeof(NSPoint));

	NSPoint *quad1 = buf;
	NSPoint *quad2 = buf + block;
	NSPoint *quad3 = quad2 + block;
	NSPoint *quad4 = quad3 + block;
	NSPoint *railPoints = quad4 + block;
	quad2 += block - 1,	quad4 += block - 1;

	NSBezierPath *path = [NSBezierPath bezierPath];

	while (cnt--) {
		while (gapIndex < 10) {
			float len = lengths[gapIndex];
			if (c < len || !cnt) {
				float n = (float)gapIndex + ((gapIndex) ? c - lengths[gapIndex - 1] : c) / gaps[gapIndex];
				n *= 0.1f;
				NSPoint tip = (cnt) ? CubicBezierPathPointForPoints(points, n) : points[3];
				float dx = tip.x - lastTip.x, dy = tip.y - lastTip.y;
				NSPoint pit = NSMakePoint(lastTip.x + dx / 2.0f - dy, lastTip.y + dy / 2.0f + dx);
				
				*quad1++ = NSMakePoint(rightOffset + pit.x, upperOffset + pit.y);
				*quad1++ = NSMakePoint(rightOffset + tip.x, upperOffset + tip.y);

				*quad2-- = NSMakePoint(leftOffset - pit.x, upperOffset + pit.y);
				*quad2-- = NSMakePoint(leftOffset - tip.x, upperOffset + tip.y);

				*quad3++ = NSMakePoint(leftOffset - pit.x, lowerOffset - pit.y);
				*quad3++ = NSMakePoint(leftOffset - tip.x, lowerOffset - tip.y);

				*quad4-- = NSMakePoint(rightOffset + pit.x, lowerOffset - pit.y);
				*quad4-- = NSMakePoint(rightOffset + tip.x, lowerOffset - tip.y);
				
				lastLength = len, lastTip = tip, lastN = n;
				break;
			} else 
				gapIndex++;
		}
		lastC = c;
		c += step;
	}

	int quarter = pointCount * 2;
	NSPoint *pntPtr = buf;	
	
	[path moveToPoint:pntPtr[0]];
	// quad1
	[path appendBezierPathWithPoints:&pntPtr[1] count:quarter - 1];
	// top horizontal rail
	if (hRailCount)
		[path _joc_jaggedLineToPoint:pntPtr[quarter] teeth:hRailCount width:step buffer:railPoints];
	// quad2
	[path appendBezierPathWithPoints:pntPtr = &pntPtr[quarter] count:quarter];
	// left vertical rail
	if (vRailCount)
		[path _joc_jaggedLineToPoint:pntPtr[quarter] teeth:vRailCount width:step buffer:railPoints];
	else 
		[path lineToPoint:NSMakePoint(NSMinX(r) - hMod / 2.0f, NSMidY(r))];
	// quad3
	[path appendBezierPathWithPoints:pntPtr = &pntPtr[quarter] count:quarter];
	// bottom horizontal rail
	if (hRailCount)
		[path _joc_jaggedLineToPoint:pntPtr[quarter] teeth:hRailCount width:step buffer:railPoints];
	// quad4
	[path appendBezierPathWithPoints:pntPtr = &pntPtr[quarter] count:quarter];
	// right vertical rail
	// NSMakePoint(NSMaxX(r) + hMod / 2.0f, NSMidY(r) + bOffset)
	NSPoint lastPoint = NSMakePoint(NSMaxX(r) + hMod / 2.0f, NSMidY(r) + bOffset);
	if (vRailCount)
		[path _joc_jaggedLineToPoint:buf[0] teeth:vRailCount width:step buffer:railPoints];
	else 
		[path lineToPoint:lastPoint];
	
	free(buf);
	[path closePath];
	
	return path;
	
}

static NSRect RectWithFlippedNegativeDimensions(NSRect r) {
	if (NSHeight(r) < 0.0f) {
		r.size.height = -r.size.height;
		r.origin.y -= r.size.height;
	}
	if (NSWidth(r) < 0.0f) {
		r.size.width = -r.size.width;
		r.origin.x -= r.size.width;
	}
	return r;
}

+ (NSBezierPath *)bezierPathWithJaggedPillInRect:(NSRect)r spacing:(float)spacing {
	
	r = RectWithFlippedNegativeDimensions(r);
	float a, b;
	a = b = (NSWidth(r) / NSHeight(r) > 1.0f) ? NSHeight(r) / 2.0f : NSWidth(r) / 2.0f;
	r = [self _joc_validRectWithRect:r a:&a b:&b spacing:&spacing];
	if (spacing < 1.0f) return [NSBezierPath bezierPathWithRoundRectInRect:r radius:a];
	return [self _joc_bezierPathWithJaggedRoundedRectInRect:r a:a b:b spacing:spacing];

}

+ (NSBezierPath *)bezierPathWithJaggedOvalInRect:(NSRect)r spacing:(float)spacing {
	
	r = RectWithFlippedNegativeDimensions(r);
	if (NSWidth(r) < 4.0f || NSHeight(r) < 4.0f || spacing < 3.0f) goto ABORT;
	float a = NSWidth(r) / 2.0f, b = NSHeight(r) / 2.0f;
	r = [self _joc_validRectWithRect:r a:&a b:&b spacing:&spacing];
	if (spacing < 2.0f) goto ABORT;
	return [self _joc_bezierPathWithJaggedRoundedRectInRect:r a:a b:b spacing:spacing];
	
ABORT:;
	return [NSBezierPath bezierPathWithOvalInRect:r];
	
}

+ (NSBezierPath *)bezierPathWithTriangleInRect:(NSRect)r edge:(NSRectEdge)edge {
	NSBezierPath *bp = [NSBezierPath bezierPath];

	NSPoint points[3];
	switch (edge) {
		case NSMinXEdge:;
			points[0] = NSMakePoint(NSMinX(r), NSMinY(r));
			points[1] = NSMakePoint(points[0].x, NSMaxY(r));
			points[2] = NSMakePoint(NSMaxX(r), NSMidY(r));
			break;
		case NSMaxXEdge:;
			points[0] = NSMakePoint(NSMaxX(r), NSMinY(r));
			points[1] = NSMakePoint(points[0].x, NSMaxY(r));
			points[2] = NSMakePoint(NSMinX(r), NSMidY(r));
			break;
		case NSMinYEdge:;
			points[0] = NSMakePoint(NSMinX(r), NSMinY(r));
			points[1] = NSMakePoint(NSMaxX(r), points[0].y);
			points[2] = NSMakePoint(NSMidX(r), NSMaxY(r));
			break;
		case NSMaxYEdge:;
			points[0] = NSMakePoint(NSMinX(r), NSMaxY(r));
			points[1] = NSMakePoint(NSMaxX(r), points[0].y);
			points[2] = NSMakePoint(NSMidX(r), NSMinY(r));
			break;
		default: break;
	}
	[bp moveToPoint:points[0]];
	[bp appendBezierPathWithPoints:&points[1] count:2];
	return bp;
}

+ (NSBezierPath*)bezierPathWithRoundRectInRect:(NSRect)aRect radius:(float)radius
{
   NSBezierPath* path = [self bezierPath];
   radius = MIN(radius, 0.5f * MIN(NSWidth(aRect), NSHeight(aRect)));
   NSRect rect = NSInsetRect(aRect, radius, radius);
   [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(rect), NSMinY(rect)) 
                                          radius:radius startAngle:180.0 endAngle:270.0];
   [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(rect), NSMinY(rect)) 
                                          radius:radius startAngle:270.0 endAngle:360.0];
   [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(rect), NSMaxY(rect)) 
                                          radius:radius startAngle:  0.0 endAngle: 90.0];
   [path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(rect), NSMaxY(rect)) 
                                          radius:radius startAngle: 90.0 endAngle:180.0];
   [path closePath];
   return path;
}

@end