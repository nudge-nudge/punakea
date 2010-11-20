//
//  FVColorMenuView.h
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

#import <Cocoa/Cocoa.h>

@class FVColorMenuMatrix;

/** @internal @brief Finder label menu view.
 
 FVColorMenuView provides an NSView subclass that is a close approximation of the Finder label color control.  Presently it's only available directly in code, but is easy to set up in code:
 @code
 NSMenuItem *anItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"Finder Label" 
                                                                           action:@selector(changeFinderLabel:)
                                                                    keyEquivalent:@""];
 FVColorMenuView *menuView = [FVColorMenuView menuView];
 // target will be first responder
 [menuView setTarget:nil]; 
 [menuView setAction:@selector(changeFinderLabel:)];
 [anItem setView:menuView];
 // add anItem to a menu
 @endcode
 
 Although this class is marked for internal use only, it should be useful elsewhere.  It's dependent on the FVColorMenuView.nib, so make sure to copy that if you use this class.
 
 */
@interface FVColorMenuView : NSControl
{
    IBOutlet FVColorMenuMatrix *_matrix;
    IBOutlet NSTextField       *_labelField;
    IBOutlet NSTextField       *_labelNameField;
    SEL                         _action;
    id                          _target;
}

/** @brief Returns a new, autoreleased instance.
 
 This is the primary interface for returning a new menu view.  It handles loading UI elements from the nib and setting up connections.
 @warning Do not use initWithFrame: to create a new instance. */
+ (FVColorMenuView *)menuView;

/** @brief Select a given Finder label.
 
 For programmatic selection changes.
 @param label An index between 0 and 7. */
- (void)selectLabel:(NSUInteger)label;

/** @brief Target for control action.
 
 Target must implement @code -(NSInteger)tag @endcode to return the selected Finder label.
 @param target The receiver of the view's action selector. */
- (void)setTarget:(id)target;
/** The control's target. */
- (id)target;

/** Action for selection changes. */
- (SEL)action;
/** Sets the action for selection changes.
 
 @param action Action will be sent to the control's target. */
- (void)setAction:(SEL)action;

@end

/*
 
 The following undocumented classes are only declared for IB.  Do not rely on them or use them outside the FVColorMenuView implementation.

 */
@interface FVColorMenuCell : NSButtonCell
@end

@interface FVColorMenuMatrix : NSMatrix
{
    NSInteger _boxedRow;
    NSInteger _boxedColumn;
}
- (NSString *)boxedLabelName;

@end
