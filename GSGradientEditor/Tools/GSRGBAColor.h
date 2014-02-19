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

- (instancetype)initWithColor:(GSRGBAColor_SystemColorClass *)color;
- (void)setColor:(GSRGBAColor_SystemColorClass *)color;
- (GSRGBAColor_SystemColorClass *)color;

@end
