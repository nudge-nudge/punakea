//
//  FVColorMenuView.m
//  colormenu
//
//  Created by Adam Maxwell on 02/20/08.
/*
 This software is Copyright (c) 2008-2010
 Adam Maxwell. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:
 
 - Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 
 - Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in
 the documentation and/or other materials provided with the
 distribution.
 
 - Neither the name of Adam Maxwell nor the names of any
 contributors may be used to endorse or promote products derived
 from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "FVColorMenuView.h"
#import "FVUtilities.h"
#import <FileView/FVFinderLabel.h>

static NSString * const FVColorNameUpdateNotification = @"FVColorNameUpdateNotification";

@implementation FVColorMenuView

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeConditionalObject:_target forKey:@"_target"];
    if (_action)
        [coder encodeObject:NSStringFromSelector(_action) forKey:@"_action"];
}

// Copying the menu calls -initWithCoder:, but it doesn't recreate subviews or connections (or both?).
- (id)awakeAfterUsingCoder:(NSCoder *)coder
{
    id target = [self target];
    SEL action = [self action];
    [self release];
    self = [[FVColorMenuView menuView] retain];
    [self setAction:action];
    [self setTarget:target];
    return self;
}

- (id)initWithFrame:(NSRect)aRect
{
    self = [super initWithFrame:aRect];
    if (self) {
        _target = nil;
        _action = nil;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    _target = [coder decodeObjectForKey:@"_target"];
    NSString *selString = [coder decodeObjectForKey:@"_action"];
    _action = selString ? NSSelectorFromString(selString) : NULL;
    return self;
}

- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_handleColorNameUpdate:) name:FVColorNameUpdateNotification object:nil];
    [_labelNameField setStringValue:@""];
    [[_labelField cell] setFont:[NSFont menuFontOfSize:0]];
    NSBundle *bundle = [NSBundle bundleForClass:[FVColorMenuView self]];
    [_labelField setStringValue:NSLocalizedStringFromTableInBundle(@"Label:", @"FileView", bundle, @"Finder label menu item title")];
    [_labelField sizeToFit];
    
    [_matrix setTarget:self];
    [_matrix setAction:@selector(fvLabelColorAction:)];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

// notification posted in response to a mouseover so we can update the label name
- (void)_handleColorNameUpdate:(NSNotification *)note
{
    if ([note object] == _matrix)
        [_labelNameField setStringValue:[_matrix boxedLabelName]];
}

- (void)setTarget:(id)target { _target = target; }

- (id)target { return _target; }

- (SEL)action { return _action; }

- (void)setAction:(SEL)action { _action = action; }

- (void)fvLabelColorAction:(id)sender
{
    [NSApp sendAction:[self action] to:[self target] from:self];
}

- (void)selectLabel:(NSUInteger)label;
{
    NSParameterAssert(nil != _matrix);
    [_matrix selectCellWithTag:label];
}

- (NSInteger)selectedTag;
{
    NSParameterAssert(nil != [_matrix selectedCell]); 
    return [[_matrix selectedCell] tag];
}

// called by the action receiver
- (NSInteger)tag
{
    return [self selectedTag];
}

+ (FVColorMenuView *)menuView;
{
    FVColorMenuView *menuView = nil;
    
    NSNib *nib = [[NSNib alloc] initWithNibNamed:@"FVColorMenuView" bundle:[NSBundle bundleForClass:[FVColorMenuView self]]];
    NSArray *objects;
    
    if ([nib instantiateNibWithOwner:nil topLevelObjects:&objects]) {
        NSParameterAssert([objects count] > 0);
        NSUInteger i = [objects count];
        while (i--) {
            if ([objects objectAtIndex:i] != NSApp)
                menuView = [[[objects objectAtIndex:i] retain] autorelease];
        }
        [objects makeObjectsPerformSelector:@selector(release)];
    }
    [nib release];
    return menuView;
}

@end

@implementation FVColorMenuCell

#define NO_BOX -1

static NSRect __FVSquareRectCenteredInRect(const NSRect iconRect)
{
    // determine aspect ratio (copy paste from FVIcon)
    const NSSize s = (NSSize){ 128, 128 };
    
    CGFloat ratio = MIN(NSWidth(iconRect) / s.width, NSHeight(iconRect) / s.height);
    NSRect dstRect = iconRect;
    dstRect.size.width = ratio * s.width;
    dstRect.size.height = ratio * s.height;
    
    CGFloat dx = (iconRect.size.width - dstRect.size.width) / 2;
    CGFloat dy = (iconRect.size.height - dstRect.size.height) / 2;
    dstRect.origin.x += dx;
    dstRect.origin.y += dy;
    
    return dstRect;
}

- (void)drawInteriorWithFrame:(NSRect)frame inView:(NSView *)controlView
{
    frame = __FVSquareRectCenteredInRect(frame);
    CGFloat inset = NSWidth(frame) / 5;
    NSRect interiorFrame = NSInsetRect(frame, inset, inset);
    NSInteger tag = [self tag];
    
    [NSGraphicsContext saveGraphicsState];

    if (0 == tag) {
        interiorFrame = NSInsetRect(interiorFrame, 2, 2);
        NSBezierPath *p = [NSBezierPath bezierPath];
        [p moveToPoint:interiorFrame.origin];
        [p lineToPoint:NSMakePoint(NSMaxX(interiorFrame), NSMaxY(interiorFrame))];
        [p moveToPoint:NSMakePoint(NSMinX(interiorFrame), NSMaxY(interiorFrame))];
        [p lineToPoint:NSMakePoint(NSMaxX(interiorFrame), NSMinY(interiorFrame))];
        [p setLineWidth:2.0];
        [p setLineCapStyle:NSRoundLineCapStyle];
        [[NSColor darkGrayColor] setStroke];
        [p stroke];
    }
    else {
        NSShadow *labelShadow = [NSShadow new];
        [labelShadow setShadowOffset:NSMakeSize(0, -1)];
        [labelShadow setShadowBlurRadius:2.0];
        [labelShadow set];
        [FVFinderLabel drawFinderLabel:tag inRect:interiorFrame roundEnds:NO];
        [labelShadow release];
    }
    
    [NSGraphicsContext restoreGraphicsState];
}

@end

@implementation FVColorMenuMatrix

- (void)removeTrackingAreas
{
    NSEnumerator *trackEnum = [[NSArray arrayWithArray:[self trackingAreas]] objectEnumerator];
    NSTrackingArea *area;
    while ((area = [trackEnum nextObject]))
        [self removeTrackingArea:area];
}

- (void)rebuildTrackingAreas
{
    [self removeTrackingAreas];
    NSUInteger r, nr = [self numberOfRows];
    NSUInteger c, nc = [self numberOfColumns];
    
    for (r = 0; r < nr; r++) {
        
        for (c = 0; c < nc; c++) {
            
            NSTrackingAreaOptions options = NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow | NSTrackingAssumeInside;
            NSRect cellFrame = [self cellFrameAtRow:r column:c];
            NSTrackingArea *area = [[NSTrackingArea alloc] initWithRect:cellFrame options:options owner:self userInfo:nil];
            [self addTrackingArea:area];
            [area release];
        }
    }
}

- (void)viewWillMoveToWindow:(NSWindow *)window
{
    _boxedRow = NO_BOX;
    _boxedColumn = NO_BOX;
    
    if (window)
        [self rebuildTrackingAreas];
    else
        [self removeTrackingAreas];
}

- (NSRect)boxRectForCellAtRow:(NSUInteger)r column:(NSUInteger)c
{
    NSRect boxRect = [self cellFrameAtRow:r column:c];
    boxRect = __FVSquareRectCenteredInRect(boxRect);
    return [self centerScanRect:NSInsetRect(boxRect, 1, 1)];
}

#define BOX_WIDTH 1.5
#define BOX_RADIUS 2

- (BOOL)_isBoxedCellSelected { return ([self selectedRow] == _boxedRow && [self selectedColumn] == _boxedColumn); }

- (BOOL)_isFirstCellSelected { return ([self selectedRow] == 0 && [self selectedColumn] == 0); }

- (void)drawRect:(NSRect)aRect
{
    [super drawRect:aRect];
        
    // draw a box around the moused-over cell (unless it's selected); the X cell always gets highlighted, since it's never drawn as selected
    if (NO_BOX != _boxedRow && NO_BOX != _boxedColumn && (NO == [self _isBoxedCellSelected] || [self _isFirstCellSelected])) {
        [[NSColor lightGrayColor] setStroke];        
        NSRect boxRect = [self boxRectForCellAtRow:_boxedRow column:_boxedColumn];
        NSBezierPath *boxPath = [NSBezierPath fv_bezierPathWithRoundRect:boxRect xRadius:BOX_RADIUS yRadius:BOX_RADIUS];
        [[NSColor colorWithCalibratedWhite:0.5 alpha:0.3] setFill];
        [boxPath fill];
        [boxPath setLineWidth:BOX_WIDTH];
        [boxPath stroke];
    }
    
    // the X doesn't show as selected
    if ([self selectedRow] != 0 || [self selectedColumn] != 0) {
        [[NSColor lightGrayColor] setStroke];
        NSRect boxRect = [self boxRectForCellAtRow:[self selectedRow] column:[self selectedColumn]];
        NSBezierPath *boxPath = [NSBezierPath fv_bezierPathWithRoundRect:boxRect xRadius:BOX_RADIUS yRadius:BOX_RADIUS];
        [boxPath setLineWidth:BOX_WIDTH];
        [boxPath stroke];
    }
}

- (void)mouseEntered:(NSEvent *)event
{
    NSInteger r, c;
    if ([self getRow:&r column:&c forPoint:[self convertPoint:[event locationInWindow] fromView:nil]]) {
        _boxedRow = r;
        _boxedColumn = c;
    }
    else {
        _boxedRow = NO_BOX;
        _boxedColumn = NO_BOX;
    }       
    [self setNeedsDisplay:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:FVColorNameUpdateNotification object:self];
    [super mouseEntered:event];
}

- (void)mouseExited:(NSEvent *)event
{
    _boxedRow = NO_BOX;
    _boxedColumn = NO_BOX;
    [self setNeedsDisplay:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:FVColorNameUpdateNotification object:self];
    [super mouseExited:event];
}

- (NSString *)boxedLabelName;
{
    NSCell *cell = nil;
    
    // return @"" if a cell isn't hovered over
    if (NO_BOX != _boxedRow && NO_BOX != _boxedColumn)
        cell = [self cellAtRow:_boxedRow column:_boxedColumn];
    
    // Finder uses curly quotes around the name, and displays nothing for the X item
    return 0 == [cell tag] ? @"" : [NSString stringWithFormat:@"%C%@%C", 0x201C, [FVFinderLabel localizedNameForLabel:[cell tag]], 0x201D];
}

@end
