//
//  GSColorPeg.h
//  GSGradientEditor
//
//  Created by Mike Piatek-Jimenez on 12/11/13.
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
#else
@import Cocoa;
#endif

/*! GSColorPeg keeps track of a color and a location.  These are used as
 *  color points for creating gradients. 
 */
@interface GSColorPeg : NSObject
/// The color of our peg.
#ifdef GSGE_IOS
@property UIColor *color;
#else
@property NSColor *color;
#endif
/// A ratio between 0 and 1 of this peg's location on a gradient or color bar.
@property CGFloat location;
/// Whether or not the peg is selected (when shown in a gradient editor view).
@property BOOL selected;

/*! Convenience method to create a new peg with a given color and location.
 * \param color The peg's color.
 * \param location The location (between 0 and 1) where this peg should fall in the gradient.
 * \returns a new GSColorPeg object with the specified properies.
 */
#ifdef GSGE_IOS
+ (instancetype)pegWithColor:(UIColor *)color atLocation:(CGFloat)location;
#else 
+ (instancetype)pegWithColor:(NSColor *)color atLocation:(CGFloat)location;
#endif

@end
