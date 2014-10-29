//
//  GSGradientView.m
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

#import "GSGradientView.h"

// This view only supports iOS.
#ifdef GSGE_IOS

@interface GSGradientView ()
/*! Updates the start point and end point of our CAGradientLayer using our current view frame as well as our angle property.
 */
- (void)updateStartEndPoints;
@end

@implementation GSGradientView

+ (Class)layerClass {
    return [CAGradientLayer class];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews {
	// Our frame is changing, update the start and end points.
	[self updateStartEndPoints];
}

- (void)setAngle:(CGFloat)newAngle {
	_angle = newAngle;
	[self updateStartEndPoints];
}

- (void)setGradient:(GSGradient *)gradient {
	CAGradientLayer *l = (CAGradientLayer *)self.layer;
	NSMutableArray *cgColors = [NSMutableArray array];
	for (UIColor *c in gradient.colors) [cgColors addObject:(id)[c CGColor]];
	l.colors = cgColors;
	l.locations = gradient.locations;
}

- (void)setGradientColors:(NSArray *)colors locations:(NSArray *)locations {
	if (colors.count != locations.count) return;
	
	CAGradientLayer *l = (CAGradientLayer *)self.layer;
	NSMutableArray *cgColors = [NSMutableArray array];
	for (UIColor *c in colors) [cgColors addObject:(id)[c CGColor]];
	l.colors = cgColors;
	l.locations = locations;
}

- (void)updateStartEndPoints {
	CGFloat angleRadians = self.angle * M_PI / 180.;
	
	CAGradientLayer *l = (CAGradientLayer *)self.layer;
	l.startPoint = CGPointMake(0.5 + cos(angleRadians + M_PI) * 0.5, 0.5 + sin(angleRadians + M_PI) * 0.5);
	l.endPoint = CGPointMake(0.5 + cos(angleRadians) * 0.5, 0.5 + sin(angleRadians) * 0.5);
}

@end

#endif
