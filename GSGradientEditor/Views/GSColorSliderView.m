//
//  GSColorSliderView.m
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

#import "GSColorSliderView.h"

// This view only supports iOS.
#ifdef GSGE_IOS

@interface GSColorSliderView ()
/// The start point of the current event.
@property CGPoint eventStartPoint;
/// YES if an event is in progress.
@property BOOL eventStarted;

#pragma mark Geometry
/*! Convert between x values in our view bounds and a gradient ratio (location). */
- (CGFloat)ratioForX:(CGFloat)x;
/*! Convert between gradient ratios (locations) and x values in our view bounds. */
- (CGFloat)xForRatio:(CGFloat)ratio;
@end

@implementation GSColorSliderView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		[self setup];
    }
    return self;
}

- (void)awakeFromNib {
	[super awakeFromNib];
	[self setup];
}

+ (CGSize)suggestedViewSize {
	return CGSizeMake(320., 30.);
}

- (void)setValue:(CGFloat)newValue {
	newValue = MIN(newValue, 1.);
	newValue = MAX(newValue, 0);
	
	_value = newValue;
	[self setNeedsLayout];
}

#pragma mark Setup
- (void)setup {
	if (!self.slider) {
		self.slider = [[GSGradientView alloc] initWithFrame:CGRectMake(0, 0, 100, GSColorSliderHeight)];
		self.slider.layer.borderWidth = 1.;
		self.slider.layer.borderColor = [UIColor colorWithWhite:0 alpha:0.1].CGColor;
		self.slider.layer.cornerRadius = GSColorSliderHeight * 0.5;
		self.slider.translatesAutoresizingMaskIntoConstraints = NO;
		[self addSubview:self.slider];
	}
	if (!self.peg) {
		self.peg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, GSColorSliderPegSize, GSColorSliderPegSize)];
		self.peg.backgroundColor = [UIColor redColor];
		self.peg.layer.borderColor = [[UIColor whiteColor] CGColor];
		self.peg.layer.borderWidth = 2.;
		self.peg.layer.shadowOffset = CGSizeZero;
		self.peg.layer.shadowRadius = 2.;
		self.peg.layer.shadowOpacity = 0.75;
		self.peg.layer.cornerRadius = GSColorSliderPegSize * 0.5;
		self.peg.translatesAutoresizingMaskIntoConstraints = NO;
		[self addSubview:self.peg];
	}
	
	[self setNeedsUpdateConstraints];
	self.value = 0;
}

- (void)updateConstraints {
	NSDictionary *views = @{ @"slider" : self.slider,
							 @"peg"    : self.peg };
	NSDictionary *metrics = @{ @"sliderHeight" : @(GSColorSliderHeight),
							   @"pegSize"      : @(GSColorSliderPegSize) };
	
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[slider]-|"
																 options:0
																 metrics:metrics
																   views:views]];

	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[peg(==pegSize)]"
																 options:0
																 metrics:metrics
																   views:views]];

	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[slider(==sliderHeight)]"
																 options:0
																 metrics:metrics
																   views:views]];
	
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[peg(==pegSize)]"
																 options:0
																 metrics:metrics
																   views:views]];
	
	[self addConstraints:@[[NSLayoutConstraint constraintWithItem:self.slider
														attribute:NSLayoutAttributeCenterY
														relatedBy:NSLayoutRelationEqual
														   toItem:self
														attribute:NSLayoutAttributeCenterY
													   multiplier:1
														 constant:0]]];
	[self addConstraints:@[[NSLayoutConstraint constraintWithItem:self.peg
														attribute:NSLayoutAttributeCenterY
														relatedBy:NSLayoutRelationEqual
														   toItem:self
														attribute:NSLayoutAttributeCenterY
													   multiplier:1
														 constant:0]]];

	[super updateConstraints];
}

- (void)layoutSubviews {
	[super layoutSubviews];

	self.peg.center = CGPointMake([self xForRatio:self.value], self.peg.center.y);
}

- (void)setSliderStartColor:(UIColor *)startColor endColor:(UIColor *)endColor {
	[self.slider setGradientColors:@[startColor, endColor] locations:@[@(0), @(1.)]];
}

#pragma mark Geometry
- (CGFloat)ratioForX:(CGFloat)x {
	CGRect sliderR = self.slider.frame;
	return (x - (sliderR.origin.x + (0.5 * GSColorSliderHeight))) / (sliderR.size.width - GSColorSliderHeight);
}

- (CGFloat)xForRatio:(CGFloat)ratio {
	CGRect sliderR = self.slider.frame;
	return sliderR.origin.x + (ratio * (sliderR.size.width - GSColorSliderHeight)) + (0.5 * GSColorSliderHeight);
}

// These methods capture iOS touch events.  OS X support will come later.
#pragma mark Events - iOS
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if (touches.count != 1) return;	// We don't use multi-touch capability.
	
	[self.delegate colorSliderDidBeginEditing:self];
	self.value = [self ratioForX:[touches.anyObject locationInView:self].x];
	[self.delegate colorSliderChanged:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	self.value = [self ratioForX:[touches.anyObject locationInView:self].x];
	[self.delegate colorSliderChanged:self];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	self.value = [self ratioForX:[touches.anyObject locationInView:self].x];
	[self.delegate colorSliderChanged:self];
	[self.delegate colorSliderDidEndEditing:self];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[self.delegate colorSliderDidEndEditing:self];
}

@end

#endif
