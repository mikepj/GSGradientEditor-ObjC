//
//  GSColorSliderView.h
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

#import <UIKit/UIKit.h>
#import "GSGradientView.h"

#define GSColorSliderHeight (14.)
#define GSColorSliderPegSize (24.)

@class GSColorSliderView;
@protocol GSColorSliderViewDelegate
/*! Called after the slider has been changed by the user.
 * \param view The color slider object.
 */
- (void)colorSliderChanged:(GSColorSliderView *)view;

/*! Called when a user begins interacting with the color slider view.  Could use this to disable scrolling in a table view while editing, for instance.
 * \param view The color slider object.
 */
- (void)colorSliderDidBeginEditing:(GSColorSliderView *)view;
/*! Called when a user stops interacting with the color slider view.  Could use this to re-enable scrolling in a table view after editing is complete, for instance.
 * \param view The color slider object.
 */
- (void)colorSliderDidEndEditing:(GSColorSliderView *)view;
@end

/*! GSColorSliderView provides a slider with a gradient background as well as 
 *  event handling for moving the peg.  Clients should set a delegate that 
 *  conforms to the GSColorSliderViewDelegate protocol to receive updates 
 *  when the slider changes.
 */
@interface GSColorSliderView : UIView
/// The slider is a gradient view to show how the color changed if the slider moves to a given location.
@property GSGradientView *slider;
/// The peg view.
@property UIView *peg;
/// Determines the location of the peg.  Should be between 0 and 1.
@property (nonatomic) CGFloat value;
/// Our delegate.
@property (weak) id<GSColorSliderViewDelegate> delegate;

/*! While the view will do its best to display in the area it has, this will return a suggested size to use.
 * \returns A suggested size to use for our view.
 */
+ (CGSize)suggestedViewSize;

/*! This is a convenience method to set the color of the background slider.
 * \param startColor The color at the left side of the slider.
 * \param endColor The color at the right side of the slider.
 */
- (void)setSliderStartColor:(UIColor *)startColor endColor:(UIColor *)endColor;

@end
