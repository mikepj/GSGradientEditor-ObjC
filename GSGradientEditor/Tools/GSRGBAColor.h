//
//  GSRGBAColor.h
//  Seasonality Pro
//
//  Created by Mike Piatek-Jimenez on 2/19/14.
//  Copyright (c) 2014 Gaucho Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GSGradientEditorPlatform.h"

#ifdef GSGE_IOS
#define GSRGBAColor_SystemColorClass UIColor
#else
#define GSRGBAColor_SystemColorClass NSColor
#endif

/*! This class just has RGBA color components.  We use this class so we can archive GSGradients while supporting multiple platforms.  If we just archived a UIColor array in GSGradient, we wouldn't be able to reload the GSGradient on OS X. */
@interface GSRGBAColor : NSObject <NSCoding>
/// The red component of the color.  Values range from 0 to 1.
@property CGFloat redComponent;
/// The green component of the color.  Values range from 0 to 1.
@property CGFloat greenComponent;
/// The blue component of the color.  Values range from 0 to 1.
@property CGFloat blueComponent;
/// The alpha component of the color.  Values range from 0 to 1.
@property CGFloat alphaComponent;

/*! Create a GSRGBAColor using a color object of the type used by the local system.
 * \param color A UIColor on iOS or an NSColor on OS X.
 * \returns A new GSRGBAColor.
 */
- (instancetype)initWithColor:(GSRGBAColor_SystemColorClass *)color;

/*! Initialize a GSRGBAColor object using the passed in color NSDictionary.  This could be used to save a color to NSUserDefaults.
 * \param colorDictionary An NSDictionary matching the format returned by @selector(dictionaryRepresentation).
 * \returns A new GSRGBAColor
 */
- (instancetype)initWithDictionaryRepresentation:(NSDictionary *)colorDictionary;

/*! Get an NSDictionary with our settings.  Can be used later with initWithDictionaryRepresentation.
 * \returns An NSDictionary with parameters needed to identify our color.
 */
- (NSDictionary *)dictionaryRepresentation;

/*! Set the color using a color object of the type used by the local system.
 * \param color A UIColor on iOS or an NSColor on OS X.
 */
- (void)setColor:(GSRGBAColor_SystemColorClass *)color;

/*! Get an equivalent color object of the type used by the local system.
 * \returns A UIColor on iOS or an NSColor on OS X.
 */
- (GSRGBAColor_SystemColorClass *)color;

@end
