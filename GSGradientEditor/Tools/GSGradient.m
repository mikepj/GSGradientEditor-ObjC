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

@implementation GSGradient
#ifdef GSGE_IOS

- (instancetype)initWithStartingColor:(UIColor *)color1 endingColor:(UIColor *)color2 {
	return [self initWithColors:@[color1, color2]];
}

- (instancetype)initWithColors:(NSArray *)colorArray {
	if (colorArray.count == 0) return nil;
	return [self initWithColors:colorArray atLocations:NULL colorSpace:nil];
}

- (instancetype)initWithColors:(NSArray *)colorArray atLocations:(const CGFloat *)locs colorSpace:(id)colorSpace {
	// colorSpace ignored
	if (self = [super init]) {
		self.colors = colorArray;
		CGFloat locationFloats[colorArray.count];
		
		if (locs != NULL) {
			NSMutableArray *newLocs = [NSMutableArray array];
			int i;
			for (i = 0; i < colorArray.count; i++) {
				[newLocs addObject:@(locs[i])];
				locationFloats[i] = locs[i];
			}
			self.locations = newLocs;
		}
		else {
			NSMutableArray *newLocs = [NSMutableArray array];
			CGFloat interval = 1. / ((CGFloat)colorArray.count - 1.);
			for (NSInteger i = 0; i < colorArray.count; i++) {
				[newLocs addObject:@((CGFloat)i * interval)];
				locationFloats[i] = (CGFloat)i * interval;
			}
			self.locations = newLocs;
		}
		
		NSMutableArray *cgColors = [NSMutableArray array];
		for (UIColor *c in colorArray) {
			CFArrayAppendValue((CFMutableArrayRef)cgColors, [c CGColor]);
		}
		
		self.cgGradient = CGGradientCreateWithColors(NULL, (CFArrayRef)cgColors, locationFloats);
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self = [self init]) {
		self.colors = [aDecoder decodeObjectForKey:@"GSGradient Colors"];
		self.locations = [aDecoder decodeObjectForKey:@"GSGradient Locations"];
		
		// Create the CGGradientRef
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
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:self.colors forKey:@"GSGradient Colors"];
	[aCoder encodeObject:self.locations forKey:@"GSGradient Locations"];
}

- (void)dealloc {
	if (self.cgGradient != NULL) {
		CGGradientRelease(self.cgGradient);
		self.cgGradient = NULL;
	}
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

- (UIColor *)interpolatedColorAtLocation:(CGFloat)location {
	if (self.colors.count == 0) return nil;
	if (self.colors.count == 1) return self.colors[0];
	if (location < [self.locations[0] floatValue] + 0.0001) return self.colors[0];
	if (location > [[self.locations lastObject] floatValue] - 0.0001) return [self.colors lastObject];
	
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
	
	CGFloat fraction = (location - [self.locations[upperIndex - 1] floatValue]) / ([self.locations[upperIndex] floatValue] - [self.locations[upperIndex - 1] floatValue]);
	
	return [UIColor colorWithRed:(red1 * (1 - fraction)) + (red2 * fraction)
						   green:(green1 * (1 - fraction)) + (green2 * fraction)
							blue:(blue1 * (1 - fraction)) + (blue2 * fraction)
						   alpha:(alpha1 * (1 - fraction)) + (alpha2 * fraction)];
}

#endif
@end
