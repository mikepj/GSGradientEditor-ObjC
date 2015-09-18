//
//  GSColorEditorView.h
//  GSGradientEditor
//
//  Created by Mike Piatek-Jimenez on 1/15/14.
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
#import "GSColorSliderView.h"

@class GSColorEditorView;
@protocol GSColorEditorViewDelegate
/*! Called after the color has been changed by the user.
 * \param view The color view object.
 */
- (void)colorEditorChanged:(GSColorEditorView *)view;

/*! Called when a user begins interacting with the color editor view.  Could use this to disable scrolling in a table view while editing, for instance.
 * \param view The color view object.
 */
- (void)colorEditorDidBeginEditing:(GSColorEditorView *)view;
/*! Called when a user stops interacting with the color editor view.  Could use this to re-enable scrolling in a table view after editing is complete, for instance.
 * \param view The color view object.
 */
- (void)colorEditorDidEndEditing:(GSColorEditorView *)view;
@end

/*! The GSColorEditorView will show 4 sliders for RGBA and allow the user to edit 
 *  a color.  Clients should set a delegate conforming to the GSColorEditorView 
 *  protocol to get updates when the color changes. 
 */
@interface GSColorEditorView : UIView <GSColorSliderViewDelegate>
/// The color shown.
@property (nonatomic) UIColor *color;
/// Labels for our color sliders.
@property UILabel *redLabel, *greenLabel, *blueLabel, *alphaLabel;
/// The color sliders themselves.
@property GSColorSliderView *redSlider, *greenSlider, *blueSlider, *alphaSlider;
/// Transparent spacing views to insert between the sliders, so AutoLayout can work correctly.
@property UIView *redGreenSpacer, *greenBlueSpacer, *blueAlphaSpacer;
/// Our delegate.
@property (weak) id<GSColorEditorViewDelegate> delegate;

/*! While the view will do its best to display in the area it has, this will return a suggested size to use.
 * \returns A suggested size to use for our view.
 */
+ (CGSize)suggestedViewSize;

@end

#endif