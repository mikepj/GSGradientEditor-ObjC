//
//  GSGradient.h
//  GSGradientEditor
//
//  Created by Mike Piatek-Jimenez on 2/2/10.
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

#define GSGRADIENT_QUICK_GRADATIONS (256.)

#ifdef GSGE_IOS
@import UIKit;
#else
@import Cocoa;
#endif

NS_ASSUME_NONNULL_BEGIN

/*! GSGradient emulates an NSGradient object on OS X.  When run on OS X, we just 
 *  subclass NSGradient and leave the implementation blank.  On iOS, we subclass 
 *  NSObject and implement some of the more common NSGradient functionality using
 *  CGGradientRefs. 
 */
#ifdef GSGE_IOS
@interface GSGradient : NSObject <NSCoding,NSCopying>
#else
@interface GSGradient : NSGradient
#endif

/// Array of UIColors.
@property (readonly) NSArray<GSGradient_SystemColorClass *> *colors;
/// Array of NSNumber locations (0 -> 1).
@property (readonly) NSArray<NSNumber *> *locations;
/// Our CGGradientRef to hold the actual gradient.
@property CGGradientRef cgGradient;

/// If we would like to change the range of the gradient from 0->1 to something else, this property can be used to hold the minimum value.  This range would be used in interpolatedColorAtLocation and quickInterpolatedColorAtLocation.
///
/// Extended functionality beyond OS X's NSGradient class.
@property (nonatomic) NSDecimalNumber *decimalMinValue;
/// If we would like to change the range of the gradient from 0->1 to something else, this property can be used to hold the maximum value.  This range would be used in interpolatedColorAtLocation and quickInterpolatedColorAtLocation.
///
/// Extended functionality beyond OS X's NSGradient class.
@property (nonatomic) NSDecimalNumber *decimalMaxValue;

/// This is a CGFloat shortcut to set a decimalMinValue.
///
/// Extended functionality beyond OS X's NSGradient class.
@property CGFloat minValue;
/// This is a CGFloat shortcut to set a decimalMaxValue.
///
/// Extended functionality beyond OS X's NSGradient class.
@property CGFloat maxValue;

// NSGradient on OS X already defines these methods.
#ifdef GSGE_IOS
/*! Create a gradient with a starting and ending color.
 * \param color1 The color at location 0 of the gradient.
 * \param color2 The color at location 1 of the gradient.
 * \returns A new GSGradient object.
 */
- (instancetype)initWithStartingColor:(GSGradient_SystemColorClass *)color1 endingColor:(GSGradient_SystemColorClass *)color2;

/*! Create a gradient with the given colors.  It is assumed that the locations of these colors are evenly spaced across the gradient.
 * \param colorArray An array of UIColors.
 * \returns A new GSGradient object.
 */
- (nullable instancetype)initWithColors:(NSArray<GSGradient_SystemColorClass *> *)colorArray;

/*! Create a gradient with the given colors and locations.  The colorSpace parameter is retained for compatibility with NSGradient on OS X, but is ignored.  The size of the location array must be the same as the size of the color array.
 * \param colorArray An array of colors.
 * \param locs A CGFloat buffer that must be the same size as the number of colors passed in.  Locations are assumed to be sorted in ascending order and be values between 0 and 1.
 * \param colorSpace Retained for compatibility with NSGradient on OS X.  Value is ignored.
 * \returns A new GSGradient object.
 */
- (nullable instancetype)initWithColors:(NSArray<GSGradient_SystemColorClass *> *)colorArray atLocations:(nullable const CGFloat *)locs colorSpace:(nullable id)colorSpace;
#endif

/*! Create a gradient using a dictionary representation (that might have been stored in NSUserDefaults, for example).
 * \param gradientDictionary An NSDictionary equivalent to the one returned by @selector(dictionaryRepresentation).
 * \returns A new GSGradient object.
 */
- (nullable instancetype)initWithDictionaryRepresentation:(nonnull NSDictionary *)gradientDictionary;

/*! Get NSDictionary with parameters needed to specify our gradient object.
 * \returns An NSDictionary with our gradient data.
 */
- (nullable NSDictionary *)dictionaryRepresentation;

/*! Calculate the color at a given location.  The location is in the range from decimalMinValue to decimalMaxValue.
 * \param location A value between 0 and 1.
 * \returns The color matching the gradient at the given location.
 */
- (nullable GSGradient_SystemColorClass *)interpolatedColorAtLocation:(CGFloat)location;

/*! This method will cache interpolated colors using GSGRADIENT_QUICK_GRADATIONS (256).  Interpolated colors will only be calculated once and after that the cached value will be returned. */
- (nullable GSGradient_SystemColorClass *)quickInterpolatedColorAtLocation:(CGFloat)location;

@end

NS_ASSUME_NONNULL_END
