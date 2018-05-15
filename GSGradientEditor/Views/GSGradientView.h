//
//  GSGradientView.h
//  GSGradientEditor
//
//  Created by Mike Piatek-Jimenez on 12/13/13.
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

#import "GSGradient.h"

/*! A GSGradientView is a custom view built on top of a CAGradientLayer to provide gradient drawing. */
@interface GSGradientView : UIView
/// The angle (in degrees) to draw our gradient in.  0° is right along the X-axis from the origin.
@property (nonatomic) CGFloat angle;

/*! Forwards the colors and locations on to our CAGradientLayer.
 * \param gradient A GSGradient object to gather color data from.
 */
- (void)setGradient:(nullable GSGradient *)gradient;

/*! Forwards the colors and locations on to our CAGradientLayer.  Array sizes must match.
 * \param colors An array of UIColors.
 * \param locations An array of NSNumbers between 0 and 1.
 */
- (void)setGradientColors:(nullable NSArray *)colors locations:(nullable NSArray *)locations;

@end

#endif
