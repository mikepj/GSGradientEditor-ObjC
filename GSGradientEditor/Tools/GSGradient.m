//
//  GSGradient.m
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

#import "GSGradient.h"
#import "GSRGBAColor.h"

#ifdef GSGE_IOS

@interface GSGradient ()
/// This stores the cached quick interpolated values.  Keys are NSNumbers with integer values, values are UIColor objects.
@property NSMutableDictionary<NSNumber *,UIColor *> *quickInterpolatedColors;

/*! Generates a CGGradientRef object that is equivalent to our stored color parameters.  This can be used to draw the gradient.  CGGradientRef is stored in the cgGradient property.
 */
- (void)generateCGGradient;
@end

@implementation GSGradient

- (instancetype)initWithStartingColor:(UIColor *)color1 endingColor:(UIColor *)color2 {
	if (!color1 || !color2) {
		self = nil;
		return nil;
	}
	return [self initWithColors:@[color1, color2]];
}

- (instancetype)initWithColors:(NSArray *)colorArray {
	if (colorArray.count < 2) {
		self = nil;
		return nil;
	}
	return [self initWithColors:colorArray atLocations:NULL colorSpace:nil];
}

- (instancetype)initWithColors:(NSArray *)colorArray atLocations:(const CGFloat *)locs colorSpace:(id)colorSpace {
	// colorSpace ignored
	if (self = [super init]) {
		if (colorArray.count < 2) {
			self = nil;
			return nil;
		}
		
		_colors = colorArray;
		
		if (locs != NULL) {
			NSMutableArray *newLocs = [NSMutableArray array];
			int i;
			for (i = 0; i < colorArray.count; i++) {
				[newLocs addObject:@(locs[i])];
			}
			_locations = newLocs;
		}
		else {
			NSMutableArray *newLocs = [NSMutableArray array];
			CGFloat interval = 1. / ((CGFloat)colorArray.count - 1.);
			for (NSInteger i = 0; i < colorArray.count; i++) {
				[newLocs addObject:@((CGFloat)i * interval)];
			}
			_locations = newLocs;
		}
		
		_decimalMinValue = [NSDecimalNumber zero];
		_decimalMaxValue = [NSDecimalNumber one];
		
		// Create the CGGradientRef
		[self generateCGGradient];
	}
	return self;
}

- (instancetype)initWithDictionaryRepresentation:(NSDictionary *)gradientDictionary {
	if (self = [self init]) {
		if (!gradientDictionary) {
			self = nil;
			return nil;
		}
		
		NSArray *colorArray = gradientDictionary[@"GSGradient Colors"];
		NSArray *locationArray = gradientDictionary[@"GSGradient Locations"];
		if (colorArray.count != locationArray.count) {
			self = nil;
			return nil;
		}
		
		NSMutableArray *newColors = [NSMutableArray array];
		for (NSDictionary *colorDictionary in colorArray) {
			GSRGBAColor *rgbaColor = [[GSRGBAColor alloc] initWithDictionaryRepresentation:colorDictionary];
			if (rgbaColor) {
				[newColors addObject:[rgbaColor color]];
			}
			else {
				self = nil;
				return nil;
			}
		}
		
		_colors = newColors;
		_locations = locationArray;
		
		_decimalMinValue = gradientDictionary[@"GSGradient MinValue"];
		if (!_decimalMinValue) _decimalMinValue = [NSDecimalNumber zero];
		_decimalMaxValue = gradientDictionary[@"GSGradient MaxValue"];
		if (!_decimalMaxValue) _decimalMaxValue = [NSDecimalNumber one];
		
		// Create the CGGradientRef
		[self generateCGGradient];
	}
	return self;
}

- (NSDictionary *)dictionaryRepresentation {
	NSMutableArray *colorDictionaries = [NSMutableArray array];
	for (UIColor *c in self.colors) [colorDictionaries addObject:[[[GSRGBAColor alloc] initWithColor:c] dictionaryRepresentation]];
	
	if (colorDictionaries.count == self.locations.count) {
		return @{ @"GSGradient Colors" : colorDictionaries,
				  @"GSGradient Locations" : self.locations,
				  @"GSGradient MinValue" : self.decimalMinValue,
				  @"GSGradient MaxValue" : self.decimalMaxValue };
	}
	else {
		return nil;
	}
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	if (self = [self init]) {
		NSArray *colorArray = [aDecoder decodeObjectForKey:@"GSGradient Colors"];
		// Convert the array to UIColors if needed.
		NSMutableArray *convertedArray = [NSMutableArray array];
		for (id c in colorArray) {
			if ([c isKindOfClass:[GSRGBAColor class]]) {
				[convertedArray addObject:[(GSRGBAColor *)c color]];
			}
		}
		
		_colors = convertedArray;
		_locations = [aDecoder decodeObjectForKey:@"GSGradient Locations"];
		
		_decimalMinValue = [aDecoder decodeObjectForKey:@"GSGradient MinValue"];
		if (!_decimalMinValue) _decimalMinValue = [NSDecimalNumber zero];
		_decimalMaxValue = [aDecoder decodeObjectForKey:@"GSGradient MaxValue"];
		if (!_decimalMaxValue) _decimalMaxValue = [NSDecimalNumber one];

		// Create the CGGradientRef
		[self generateCGGradient];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	NSMutableArray *rgbaColors = [NSMutableArray array];
	for (UIColor *c in self.colors) [rgbaColors addObject:[[GSRGBAColor alloc] initWithColor:c]];
	
	[aCoder encodeObject:rgbaColors forKey:@"GSGradient Colors"];
	[aCoder encodeObject:self.locations forKey:@"GSGradient Locations"];
	[aCoder encodeObject:self.decimalMinValue forKey:@"GSGradient MinValue"];
	[aCoder encodeObject:self.decimalMaxValue forKey:@"GSGradient MaxValue"];
}

- (void)dealloc {
	if (_cgGradient) {
		CGGradientRelease(_cgGradient);
		_cgGradient = NULL;
	}
}

- (void)setDecimalMinValue:(NSDecimalNumber *)decimalMinValue {
	_decimalMinValue = decimalMinValue;
	[self.quickInterpolatedColors removeAllObjects];
}

- (void)setDecimalMaxValue:(NSDecimalNumber *)decimalMaxValue {
	_decimalMaxValue = decimalMaxValue;
	[self.quickInterpolatedColors removeAllObjects];
}

- (void)setMinValue:(CGFloat)minValue {
	self.decimalMinValue = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f", minValue] locale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
}

- (CGFloat)minValue {
	return [self.decimalMinValue doubleValue];
}

- (void)setMaxValue:(CGFloat)maxValue {
	self.decimalMaxValue = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f", maxValue] locale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
}

- (CGFloat)maxValue {
	return [self.decimalMaxValue doubleValue];
}

- (NSString *)description {
	NSMutableString *colorString = [NSMutableString string];
	for (NSUInteger i = 0; (i < self.colors.count) && (i < self.locations.count); i++) {
		CGFloat r, g, b, a;
		if ([(UIColor *)self.colors[i] getRed:&r green:&g blue:&b alpha:&a]) {
			[colorString appendFormat:@"  Color: %.3f, %.3f, %.3f, %.3f    Location: %.3f\n", r, g, b, a, [self.locations[i] floatValue]];
		}
		else {
			[colorString appendFormat:@"  Color: %@    Location: %.3f\n", self.colors[i], [self.locations[i] floatValue]];
		}
	}
	
	return [NSString stringWithFormat:@"GSGradient {\n%@}", colorString];
}

- (void)generateCGGradient {
	if (self.locations.count < 2) return;
	if (self.colors.count < 2) return;
	
	CGFloat locationFloats[self.locations.count];
	for (NSUInteger i = 0; i < self.locations.count; i++) {
		locationFloats[i] = [self.locations[i] floatValue];
	}
	
	NSMutableArray *cgColors = [NSMutableArray array];
	for (UIColor *c in self.colors) {
		CFArrayAppendValue((CFMutableArrayRef)cgColors, [c CGColor]);
	}
	
	self.cgGradient = CGGradientCreateWithColors(NULL, (CFArrayRef)cgColors, locationFloats);
}

- (UIColor *)interpolatedColorAtLocation:(CGFloat)location {
	[self checkMinMax];
	
	CGFloat scaledLocation = [self scaledLocation:location];
	
	if (self.colors.count == 0) return nil;
	if (self.colors.count == 1) return self.colors[0];
	if (scaledLocation < 0.0001) return self.colors[0];
	if (scaledLocation > 0.9999) return [self.colors lastObject];
	
	NSInteger upperIndex = -1;
	for (NSUInteger i = 0; i < self.locations.count; i++) {
		CGFloat L = [self.locations[i] floatValue];
		if (location < L) {
			upperIndex = i;
			break;
		}
	}
	
	if (upperIndex <= 0) return self.colors[0];
	if (upperIndex > self.colors.count - 1) return [self.colors lastObject];
	
	CGFloat red1 = 0, red2 = 0, green1 = 0, green2 = 0, blue1 = 0, blue2 = 0, alpha1 = 0, alpha2 = 0;
	if (![(UIColor *)self.colors[upperIndex - 1] getRed:&red1 green:&green1 blue:&blue1 alpha:&alpha1]) return nil;
	if (![(UIColor *)self.colors[upperIndex] getRed:&red2 green:&green2 blue:&blue2 alpha:&alpha2]) return nil;
	
	CGFloat fraction = (scaledLocation - [self.locations[upperIndex - 1] floatValue]) / ([self.locations[upperIndex] floatValue] - [self.locations[upperIndex - 1] floatValue]);
	
	return [UIColor colorWithRed:(red1 * (1 - fraction)) + (red2 * fraction)
						   green:(green1 * (1 - fraction)) + (green2 * fraction)
							blue:(blue1 * (1 - fraction)) + (blue2 * fraction)
						   alpha:(alpha1 * (1 - fraction)) + (alpha2 * fraction)];
}

- (nullable UIColor *)quickInterpolatedColorAtLocation:(CGFloat)location {
	if (!self.quickInterpolatedColors) {
		self.quickInterpolatedColors = [NSMutableDictionary dictionary];
	}
	
	[self checkMinMax];
	
	CGFloat scaledLocation = [self scaledLocation:location];
	NSInteger gradation = round(scaledLocation * GSGRADIENT_QUICK_GRADATIONS);
	if (gradation >= GSGRADIENT_QUICK_GRADATIONS) gradation = GSGRADIENT_QUICK_GRADATIONS - 1;
	if (gradation < 0) gradation = 0;
	
	NSNumber *gradationNumber = [NSNumber numberWithInteger:gradation];
	
	UIColor *cachedColor = self.quickInterpolatedColors[gradationNumber];
	if (cachedColor) {
		return cachedColor;
	}
	else {
		UIColor *interpolatedColor = [self interpolatedColorAtLocation:self.minValue + ((CGFloat)gradation / GSGRADIENT_QUICK_GRADATIONS * (self.maxValue - self.minValue))];
		if (interpolatedColor) {
			self.quickInterpolatedColors[gradationNumber] = interpolatedColor;
		}
		return interpolatedColor;
	}
}

/// This returns a location that is scaled from a value between (self.minValue, self.maxValue) to a value between (0, 1) to match the color locations set in the gradient.
- (CGFloat)scaledLocation:(CGFloat)location {
	return (location - self.minValue) / (self.maxValue - self.minValue);
}

/// This method checks to make sure self.minValue < self.maxValue before performing a calculation that expects this to be the case.
- (void)checkMinMax {
	if (self.maxValue <= self.minValue) {
		NSLog(@"[GSGradient checkMinMax] Resetting min (%f) and max (%f) values of the gradient:  max must be > min", self.minValue, self.maxValue);
		self.decimalMinValue = [NSDecimalNumber zero];
		self.decimalMaxValue = [NSDecimalNumber one];
	}
}

@end

#else

@implementation GSGradient
@end

#endif
