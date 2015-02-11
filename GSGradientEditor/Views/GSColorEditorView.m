//
//  GSColorEditorView.m
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

#import "GSColorEditorView.h"

// This view only supports iOS.
#ifdef GSGE_IOS

@interface GSColorEditorView ()
- (void)setup;
- (UILabel *)createLabelWithText:(NSString *)text;
- (void)updateDisplay;
@end

@implementation GSColorEditorView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		[self setup];
    }
    return self;
}

- (void)awakeFromNib {
	[self setup];
}

+ (CGSize)suggestedViewSize {
	CGFloat lineHeight = [[UIFont fontWithDescriptor:[UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleSubheadline] size:0] lineHeight];
	
	return CGSizeMake(320., MAX(150., 4 * (lineHeight + 5.)));
}

#pragma mark Setup
- (void)setup {
	if (!self.redLabel) {
		self.redLabel = [self createLabelWithText:NSLocalizedString(@"Red", @"Color Editor label.")];
		[self addSubview:self.redLabel];
	}
	if (!self.greenLabel) {
		self.greenLabel = [self createLabelWithText:NSLocalizedString(@"Green", @"Color Editor label.")];
		[self addSubview:self.greenLabel];
	}
	if (!self.blueLabel) {
		self.blueLabel = [self createLabelWithText:NSLocalizedString(@"Blue", @"Color Editor label.")];
		[self addSubview:self.blueLabel];
	}
	if (!self.alphaLabel) {
		self.alphaLabel = [self createLabelWithText:NSLocalizedString(@"Alpha", @"Color Editor label.")];
		[self addSubview:self.alphaLabel];
	}
	
	if (!self.redSlider) {
		self.redSlider = [[GSColorSliderView alloc] initWithFrame:CGRectMake(0, 0, 100., 100.)];
		self.redSlider.delegate = self;
		self.redSlider.translatesAutoresizingMaskIntoConstraints = NO;
		[self addSubview:self.redSlider];
	}
	if (!self.greenSlider) {
		self.greenSlider = [[GSColorSliderView alloc] initWithFrame:CGRectMake(0, 0, 100., 100.)];
		self.greenSlider.delegate = self;
		self.greenSlider.translatesAutoresizingMaskIntoConstraints = NO;
		[self addSubview:self.greenSlider];
	}
	if (!self.blueSlider) {
		self.blueSlider = [[GSColorSliderView alloc] initWithFrame:CGRectMake(0, 0, 100., 100.)];
		self.blueSlider.delegate = self;
		self.blueSlider.translatesAutoresizingMaskIntoConstraints = NO;
		[self addSubview:self.blueSlider];
	}
	if (!self.alphaSlider) {
		self.alphaSlider = [[GSColorSliderView alloc] initWithFrame:CGRectMake(0, 0, 100., 100.)];
		self.alphaSlider.delegate = self;
		self.alphaSlider.translatesAutoresizingMaskIntoConstraints = NO;
		[self addSubview:self.alphaSlider];
	}
	
	if (!self.redGreenSpacer) {
		self.redGreenSpacer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100., 100.)];
		self.redGreenSpacer.translatesAutoresizingMaskIntoConstraints = NO;
		[self addSubview:self.redGreenSpacer];
	}
	if (!self.greenBlueSpacer) {
		self.greenBlueSpacer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100., 100.)];
		self.greenBlueSpacer.translatesAutoresizingMaskIntoConstraints = NO;
		[self addSubview:self.greenBlueSpacer];
	}
	if (!self.blueAlphaSpacer) {
		self.blueAlphaSpacer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100., 100.)];
		self.blueAlphaSpacer.translatesAutoresizingMaskIntoConstraints = NO;
		[self addSubview:self.blueAlphaSpacer];
	}
	
	[self setNeedsUpdateConstraints];
}

- (UILabel *)createLabelWithText:(NSString *)text {
	UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100., 100.)];
	newLabel.text = text;
	newLabel.font = [UIFont fontWithDescriptor:[UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleSubheadline] size:0];
	newLabel.textAlignment = NSTextAlignmentRight;
	newLabel.textColor = [UIColor colorWithWhite:0.7 alpha:1.];
	newLabel.translatesAutoresizingMaskIntoConstraints = NO;
	[newLabel sizeToFit];
	return newLabel;
}

#pragma mark View Layout and Constraints
- (void)updateConstraints {
	NSDictionary *views = @{ @"redS"            : self.redSlider,
							 @"greenS"          : self.greenSlider,
							 @"blueS"           : self.blueSlider,
							 @"alphaS"          : self.alphaSlider,
							 @"redLabel"        : self.redLabel,
							 @"greenLabel"      : self.greenLabel,
							 @"blueLabel"       : self.blueLabel,
							 @"alphaLabel"      : self.alphaLabel,
							 @"redGreenSpacer"  : self.redGreenSpacer,
							 @"greenBlueSpacer" : self.greenBlueSpacer,
							 @"blueAlphaSpacer" : self.blueAlphaSpacer };
	
	NSDictionary *metrics = @{ @"sliderHeight" : @([GSColorSliderView suggestedViewSize].height) };
	
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[redLabel]-[redS]|"
																 options:NSLayoutFormatAlignAllCenterY
																 metrics:metrics
																   views:views]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[greenLabel]-[greenS]|"
																 options:NSLayoutFormatAlignAllCenterY
																 metrics:metrics
																   views:views]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[blueLabel]-[blueS]|"
																 options:NSLayoutFormatAlignAllCenterY
																 metrics:metrics
																   views:views]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[alphaLabel]-[alphaS]|"
																 options:NSLayoutFormatAlignAllCenterY
																 metrics:metrics
																   views:views]];
	
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[redGreenSpacer]|"
																 options:0
																 metrics:metrics
																   views:views]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[greenBlueSpacer]|"
																 options:0
																 metrics:metrics
																   views:views]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[blueAlphaSpacer]|"
																 options:0
																 metrics:metrics
																   views:views]];


	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[redS(==sliderHeight)][redGreenSpacer][greenS(==sliderHeight)][greenBlueSpacer][blueS(==sliderHeight)][blueAlphaSpacer][alphaS(==sliderHeight)]|"
																 options:0
																 metrics:metrics
																   views:views]];

	// Make sure the spacers are the same height.
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[redGreenSpacer(==greenBlueSpacer)]"
																 options:0
																 metrics:metrics
																   views:views]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[redGreenSpacer(==blueAlphaSpacer)]"
																 options:0
																 metrics:metrics
																   views:views]];
	
	// Make sure the labels are the same width.
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[redLabel(==greenLabel)]"
																 options:0
																 metrics:metrics
																   views:views]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[redLabel(==blueLabel)]"
																 options:0
																 metrics:metrics
																   views:views]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[redLabel(==alphaLabel)]"
																 options:0
																 metrics:metrics
																   views:views]];
	
	[super updateConstraints];
}

#pragma mark Custom Setters
- (void)setColor:(UIColor *)newColor {
	_color = newColor;
	[self updateDisplay];
}

#pragma mark Update the Display
- (void)updateDisplay {
	if (!self.color) return;
	
	// Gather the RGBA components from our color.
	CGFloat redComponent = 0, greenComponent = 0, blueComponent = 0, alphaComponent = 1.;
	if (![self.color getRed:&redComponent green:&greenComponent blue:&blueComponent alpha:&alphaComponent]) return;
	
	// Reconfigure the color sliders.
	self.redSlider.value = redComponent;
	self.greenSlider.value = greenComponent;
	self.blueSlider.value = blueComponent;
	self.alphaSlider.value = alphaComponent;

	[self.redSlider setSliderStartColor:[UIColor colorWithRed:0 green:greenComponent blue:blueComponent alpha:1.] endColor:[UIColor colorWithRed:1. green:greenComponent blue:blueComponent alpha:1.]];
	[self.greenSlider setSliderStartColor:[UIColor colorWithRed:redComponent green:0 blue:blueComponent alpha:1.] endColor:[UIColor colorWithRed:redComponent green:1. blue:blueComponent alpha:1.]];
	[self.blueSlider setSliderStartColor:[UIColor colorWithRed:redComponent green:greenComponent blue:0 alpha:1.] endColor:[UIColor colorWithRed:redComponent green:greenComponent blue:1. alpha:1.]];
	[self.alphaSlider setSliderStartColor:[self.color colorWithAlphaComponent:0] endColor:[self.color colorWithAlphaComponent:1.]];
	
	self.redSlider.peg.backgroundColor = self.color;
	self.greenSlider.peg.backgroundColor = self.color;
	self.blueSlider.peg.backgroundColor = self.color;
	self.alphaSlider.peg.backgroundColor = self.color;
}

#pragma mark GSColorSliderViewDelegate
- (void)colorSliderChanged:(GSColorSliderView *)view {
	self.color = [UIColor colorWithRed:self.redSlider.value green:self.greenSlider.value blue:self.blueSlider.value alpha:self.alphaSlider.value];
	
	[self.delegate colorEditorChanged:self];
}

- (void)colorSliderDidBeginEditing:(GSColorSliderView *)view {
	[self.delegate colorEditorDidBeginEditing:self];
}

- (void)colorSliderDidEndEditing:(GSColorSliderView *)view {
	[self.delegate colorEditorDidEndEditing:self];
}


@end

#endif
