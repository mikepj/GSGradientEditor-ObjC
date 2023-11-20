//
//  GSGradientEditorView.h
//  GSGradientEditor
//
//  Created by Mike Piatek-Jimenez on 12/12/13.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2014 Mike Piatek-Jimenez and Gaucho Software, LLC.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "GSGradientEditorPlatform.h"

// This view only supports iOS.
#ifdef GSGE_IOS

@import UIKit;

#import "GSColorEditorView.h"
#import "GSGradientView.h"
#import "GSGradient.h"
#import "GSColorPeg.h"

#define GSGradientEditorPegSize (20.)
#define GSGradientEditorDeleteThreshold (40.)

@class GSGradientEditorView;
@protocol GSGradientEditorDelegate
/*! Called when the gradient is changed.
 * \param view The gradient view object.
 */
- (void)gradientEditorChanged:(GSGradientEditorView *)view;

/*! Called when a user selects a different peg.
 * \param view The gradient view object.
 * \param newSelection The newly selected peg object.
 */
- (void)gradientEditor:(GSGradientEditorView *)view pegSelectionChanged:(GSColorPeg *)newSelection;

/*! Called when a user begins interacting with the gradient view.  Could use this to disable scrolling in a table view while editing, for instance.
 * \param view The gradient view object.
 */
- (void)gradientEditorDidBeginEditing:(GSGradientEditorView *)view;

/*! Called when a user stops interacting with the gradient view.  Could use this to re-enable scrolling in a table view after editing is complete, for instance.
 * \param view The gradient view object.
 */
- (void)gradientEditorDidEndEditing:(GSGradientEditorView *)view;
@end

/*! GSGradientEditorView is a view that allows a user to edit a gradient.  
 *  Clients should set a delegate conforming to the GSGradientEditorDelegate protocol 
 *  to receive updates when the gradient changes.
 *
 *  Care should be taken when ivars like the gradientPreview, colorEditorView,
 *  colorPegViews and colorPegs are modified.  These ivars are public to enable
 *  customization, but in ordinary circumstances they should not be modified. 
 */
@interface GSGradientEditorView : UIView <GSColorEditorViewDelegate>
/// This view shows a preview of current gradient.
@property (strong) GSGradientView *gradientPreview;
/// This view allows a color in the gradient to be modified.
@property (strong) GSColorEditorView *colorEditorView;
/// This is an array of GSColorPegView objects.
@property (strong) NSArray *colorPegViews;
/// This is an array of GSColorPeg objects.  There must always be at least 2 pegs to have a gradient.
@property (strong,nonatomic) NSArray *colorPegs;
/// This delegate gets notified when the gradient is changed, or a new peg is selected.
@property (weak) id<GSGradientEditorDelegate> delegate;

/*! While the view will do its best to display in the area it has, this will return a suggested size to use.
 * \returns A suggested size to use for our view.
 */
+ (CGSize)suggestedViewSize;

#pragma mark Internal Peg to Client Gradient Conversion
/*! Get a GSGradient object that matches the currently viewed gradient.
 * \returns A new GSGradient object with colors and locations matching the currently shown gradient.
 */
- (GSGradient *)gradient;

/*! Update our display to match the specified gradient.
 * \param gradient A gradient object that we should match our display with.
 */
- (void)setGradient:(GSGradient *)gradient;

#pragma mark Peg Selection
/*! Get the currently selected peg.
 * \returns The currently selected peg.
 */
- (GSColorPeg *)selectedPeg;
/*! Change the peg currently selected.
 * \param desiredSelection The peg you would like to select.
 */
- (void)selectPeg:(GSColorPeg *)desiredSelection;

// These methods provide a cross-platform layer.  iOS touch events are implemented above.  OS X support will come at a later point in time.
#pragma mark Events - Cross Platform Layer
- (void)tapClickStarted:(CGPoint)atPoint;
- (void)tapClickMoved:(CGPoint)newPoint;
- (void)tapClickEnded:(CGPoint)atPoint;
- (void)tapClickCancelled;
- (void)doubleTapClicked;

@end

#endif
