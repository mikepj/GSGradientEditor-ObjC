//
//  GSRGBAColor.m
//  Seasonality Pro
//
//  Created by Mike Piatek-Jimenez on 2/19/14.
//  Copyright (c) 2014 Gaucho Software, LLC. All rights reserved.
//

#import "GSRGBAColor.h"

@implementation GSRGBAColor

- (instancetype)initWithColor:(GSRGBAColor_SystemColorClass *)color {
	if (self = [super init]) {
		[self setColor:color];
	}
	return self;
}

- (instancetype)initWithDictionaryRepresentation:(NSDictionary *)colorDictionary {
	if (self = [super init]) {
		if (!colorDictionary) { 
			self = nil;
			return nil;
		}
		
		NSNumber *r = [colorDictionary objectForKey:@"GSRGBAColor RedComponent"];
		NSNumber *g = [colorDictionary objectForKey:@"GSRGBAColor GreenComponent"];
		NSNumber *b = [colorDictionary objectForKey:@"GSRGBAColor BlueComponent"];
		NSNumber *a = [colorDictionary objectForKey:@"GSRGBAColor AlphaComponent"];
		
		if (!r || !g || !b || !a) {
			self = nil;
			return nil;
		}

		self.redComponent = [r floatValue];
		self.greenComponent = [g floatValue];
		self.blueComponent = [b floatValue];
		self.alphaComponent = [a floatValue];
	}
	return self;
}

- (NSDictionary *)dictionaryRepresentation {
	return @{ @"GSRGBAColor RedComponent" : @(self.redComponent),
			  @"GSRGBAColor GreenComponent" : @(self.greenComponent),
			  @"GSRGBAColor BlueComponent" : @(self.blueComponent),
			  @"GSRGBAColor AlphaComponent" : @(self.alphaComponent) };
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	if (self = [self init]) {
		self.redComponent = [aDecoder decodeFloatForKey:@"GSRGBAColor RedComponent"];
		self.greenComponent = [aDecoder decodeFloatForKey:@"GSRGBAColor GreenComponent"];
		self.blueComponent = [aDecoder decodeFloatForKey:@"GSRGBAColor BlueComponent"];
		self.alphaComponent = [aDecoder decodeFloatForKey:@"GSRGBAColor AlphaComponent"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeFloat:self.redComponent forKey:@"GSRGBAColor RedComponent"];
	[aCoder encodeFloat:self.greenComponent forKey:@"GSRGBAColor GreenComponent"];
	[aCoder encodeFloat:self.blueComponent forKey:@"GSRGBAColor BlueComponent"];
	[aCoder encodeFloat:self.alphaComponent forKey:@"GSRGBAColor AlphaComponent"];
}

- (void)setColor:(GSRGBAColor_SystemColorClass *)color {
#ifdef GSGE_IOS
	[color getRed:&_redComponent green:&_greenComponent blue:&_blueComponent alpha:&_alphaComponent];
#else
	NSColorSpace *colorSpace = [NSColorSpace deviceRGBColorSpace];
    NSColor *convertedColor = [color colorUsingColorSpace:colorSpace];
	
    _redComponent = [convertedColor redComponent];
	_greenComponent = [convertedColor greenComponent];
    _blueComponent = [convertedColor blueComponent];
    _alphaComponent = [convertedColor alphaComponent];
#endif
}

- (GSRGBAColor_SystemColorClass *)color {
#ifdef GSGE_IOS
	return [UIColor colorWithRed:_redComponent green:_greenComponent blue:_blueComponent alpha:_alphaComponent];
#else
	return [NSColor colorWithDeviceRed:_redComponent green:_greenComponent blue:_blueComponent alpha:_alphaComponent];
#endif
}

@end
