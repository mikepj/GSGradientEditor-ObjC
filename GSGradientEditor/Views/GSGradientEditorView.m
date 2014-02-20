//
//  GSGradientEditorView.m
//  GSGradientEditor
//
//  Created by Mike Piatek-Jimenez on 12/12/13.
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

#import "GSGradientEditorView.h"

@interface GSGradientEditorView ()
/// The start point of the current event.
@property CGPoint eventStartPoint;
/// YES if an event is in progress.
@property BOOL eventStarted;
/// YES if a move action occurred during this event.
@property BOOL eventDidMove;
/// YES if we created a new peg during this event.
@property BOOL eventDidCreatePeg;
/// The peg being modified with this event.
@property GSColorPeg *eventPeg;

#pragma mark Setup
- (void)setup;
- (void)setupGradientPreview;
- (void)setupColorEditor;

#pragma mark Update the Display
- (void)updateDisplay;
- (void)updatePreview;
- (void)updatePegs;

#pragma mark Geometry
/*! Convert between x values in our view bounds and a gradient ratio (location). */
- (CGFloat)ratioForX:(CGFloat)x;
/*! Convert between gradient ratios (locations) and x values in our view bounds. */
- (CGFloat)xForRatio:(CGFloat)ratio;
/*! Finds the closest color peg to the given x location.  A threshold of 22 pixels is used, so if no peg is within 22 pixels of the x given, nil will be returned.
 * \param x The x value in view coordinates.
 * \returns The closest GSColorPeg if one is within 22 points of the given x.
 */
- (GSColorPeg *)colorPegClosestToX:(CGFloat)x;

#pragma mark Peg Updates
/*! Add a new peg to our view. */
- (void)addPeg:(GSColorPeg *)peg;
/*! Move a peg to a new location. */
- (void)movePegAtIndex:(NSUInteger)pegIndex toLocation:(CGFloat)location;
/*! Alternative way to move a peg to a new location. */
- (void)movePeg:(GSColorPeg *)peg toLocation:(CGFloat)location;
/*! Remove a peg from our gradient. */
- (BOOL)removePegAtIndex:(NSUInteger)pegIndex;
/*! Return a sorted array of pegs from the array provided. 
 * \param pegs An array of GSColorPeg objects.
 * \returns A sorted array of GSColorPeg objects.
 */
- (NSArray *)sortedPegArray:(NSArray *)pegs;
@end

@implementation GSGradientEditorView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		[self setup];
    }
    return self;
}

- (void)awakeFromNib {
	[self setup];
}

+ (CGSize)suggestedViewSize {
	return CGSizeMake(320., 20. + 70. + 20. + [GSColorEditorView suggestedViewSize].height + 20.);
}

#pragma mark Setup
- (void)setup {
	self.colorPegs = @[[GSColorPeg pegWithColor:[UIColor colorWithRed:1. green:1. blue:1. alpha:1.] atLocation:0],
					   [GSColorPeg pegWithColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1.] atLocation:1.]];
	
	[self setupGradientPreview];
	[self setupColorEditor];
	[self setNeedsUpdateConstraints];
}

- (void)setupGradientPreview {
	if (!self.gradientPreview) {
		self.gradientPreview = [[GSGradientView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
		self.gradientPreview.layer.borderWidth = 1.;
		self.gradientPreview.layer.borderColor = [UIColor grayColor].CGColor;
		self.gradientPreview.translatesAutoresizingMaskIntoConstraints = NO;
		[self insertSubview:self.gradientPreview atIndex:0];
	}
}

- (void)setupColorEditor {
	self.colorEditorView = [[GSColorEditorView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
	self.colorEditorView.color = [UIColor colorWithRed:1. green:1. blue:1. alpha:1.];
	self.colorEditorView.delegate = self;
	self.colorEditorView.translatesAutoresizingMaskIntoConstraints = NO;
	[self addSubview:self.colorEditorView];
}

#pragma mark View Layout and Constraints
- (void)layoutSubviews {
	[super layoutSubviews];
	[self updateDisplay];
}

- (void)updateConstraints {
	NSDictionary *views = @{ @"gp" : self.gradientPreview,
							 @"ce" : self.colorEditorView };
	
	NSDictionary *metrics = @{ @"colorEditorHeight" : @([GSColorEditorView suggestedViewSize].height),
							   @"gradientPreviewHeight" : @(70) };

	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[gp]-|"
																 options:0
																 metrics:metrics
																   views:views]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[ce]|"
																 options:0
																 metrics:metrics
																   views:views]];

	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[gp(==gradientPreviewHeight)]-[ce(==colorEditorHeight)]"
																 options:0
																 metrics:metrics
																   views:views]];
	
	[super updateConstraints];
}

#pragma mark Internal Peg to Client Gradient Conversion
- (GSGradient *)gradient {
	if (self.colorPegs.count < 2) return nil;

	NSMutableArray *c = [NSMutableArray array];
	CGFloat l[self.colorPegs.count];

	NSUInteger index = 0;
	for (GSColorPeg *peg in self.colorPegs) {
		if (!peg.color) continue;
		[c addObject:peg.color];
		l[index++] = peg.location;
	}
	
	return [[GSGradient alloc] initWithColors:c atLocations:l colorSpace:nil];
}

- (void)setGradient:(GSGradient *)newGradient {
	NSMutableArray *newPegs = [NSMutableArray array];
	NSArray *gradientColors = newGradient.colors;
	NSArray *gradientLocations = newGradient.locations;
	if (gradientColors.count == gradientLocations.count) {
		for (NSUInteger i = 0; i < gradientColors.count; i++) {
			[newPegs addObject:[GSColorPeg pegWithColor:gradientColors[i] atLocation:[gradientLocations[i] floatValue]]];
		}
	}
	self.colorPegs = newPegs;
	if (newPegs.count) [self selectPeg:newPegs[0]];
}

#pragma mark Custom Setters
- (void)setColorPegs:(NSArray *)newPegArray {
	_colorPegs = newPegArray;
	
	[self.delegate gradientEditorChanged:self];
	[self updateDisplay];
}

#pragma mark Peg Updates
- (void)addPeg:(GSColorPeg *)peg {
	self.colorPegs = [self sortedPegArray:[self.colorPegs arrayByAddingObject:peg]];
}

- (void)movePegAtIndex:(NSUInteger)pegIndex toLocation:(CGFloat)location {
	if (pegIndex >= self.colorPegs.count) {
		NSLog(@"[GSGradientEditorView movePegAtIndex:%lu] Index is beyond bounds (%lu).", (unsigned long)pegIndex, (unsigned long)self.colorPegs.count);
	}
	
	[self movePeg:((GSColorPeg *)self.colorPegs[pegIndex]) toLocation:location];
}

- (void)movePeg:(GSColorPeg *)peg toLocation:(CGFloat)location {
	// Limit the range to 0-1 inclusive.
	location = MIN(location, 1.);
	location = MAX(location, 0);
	
	peg.location = location;
	self.colorPegs = [self sortedPegArray:self.colorPegs];
}

- (BOOL)removePegAtIndex:(NSUInteger)pegIndex {
	if (pegIndex >= self.colorPegs.count) {
		NSLog(@"[GSGradientEditorView removePegAtIndex:%lu] Index is beyond bounds (%lu).", (unsigned long)pegIndex, (unsigned long)self.colorPegs.count);
		return NO;
	}
	
	return [self removePeg:self.colorPegs[pegIndex]];
}

- (BOOL)removePeg:(GSColorPeg *)peg {
	if (self.colorPegs.count == 2) {
		// Need at least 2 pegs.
		NSLog(@"[GSGradientEditorView removePeg] Can't have less than two colors in a gradient.");
		return NO;
	}
	
	NSMutableArray *newPegs = [self.colorPegs mutableCopy];
	[newPegs removeObject:peg];
	self.colorPegs = newPegs;
	
	return YES;
}

- (NSArray *)sortedPegArray:(NSArray *)pegs {
	return [pegs sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		CGFloat obj1Location = ((GSColorPeg *)obj1).location;
		CGFloat obj2Location = ((GSColorPeg *)obj2).location;
		
		if (obj1Location > obj2Location) return NSOrderedDescending;
		else if (obj1Location < obj2Location) return NSOrderedAscending;
		else return NSOrderedSame;
	}];
}

#pragma mark Update the Display
- (void)updateDisplay {
	[self updatePreview];
	[self updatePegs];
}

- (void)updatePreview {
	NSMutableArray *colors = [NSMutableArray array];
	NSMutableArray *locations = [NSMutableArray array];
	for (GSColorPeg *peg in self.colorPegs) {
		if (peg.color) {
			[colors addObject:peg.color];
			[locations addObject:@(peg.location)];
		}
	}
	[self.gradientPreview setGradientColors:colors locations:locations];
}

- (void)updatePegs {
	// Make sure the number of colorPegViews matches the number of colorPegs.
	if (self.colorPegViews.count != self.colorPegs.count) {
		NSMutableArray *newViews = [self.colorPegViews mutableCopy];
		if (!newViews) newViews = [NSMutableArray array];
		while (newViews.count < self.colorPegs.count) {
			UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, GSGradientEditorPegSize, GSGradientEditorPegSize)];
			v.layer.borderColor = [[UIColor whiteColor] CGColor];
			v.layer.borderWidth = 2.;
			v.layer.shadowOffset = CGSizeZero;
			v.layer.shadowRadius = 2.;
			v.layer.shadowOpacity = 0.75;
			v.layer.cornerRadius = GSGradientEditorPegSize * 0.5;
			[self addSubview:v];
			[newViews addObject:v];
		}
		while (newViews.count > self.colorPegs.count) {
			UIView *unneededPegView = [newViews lastObject];
			
			[newViews removeObject:unneededPegView];
			[unneededPegView removeFromSuperview];
		}
		
		self.colorPegViews = newViews;
	}
	
	CGRect gradientPreviewFrame = self.gradientPreview.frame;
	CGFloat pegY = gradientPreviewFrame.origin.y + (0.5 * gradientPreviewFrame.size.height);
		
	for (NSUInteger i = 0; i < self.colorPegs.count; i++) {
		GSColorPeg *peg = self.colorPegs[i];
		UIView *pegView = self.colorPegViews[i];
		pegView.backgroundColor = peg.color;
		pegView.center = CGPointMake(gradientPreviewFrame.origin.x + [self xForRatio:peg.location], pegY);
		pegView.layer.borderWidth = peg.selected ? 3. : 1.;
	}
}

#pragma mark Peg Selection
- (GSColorPeg *)selectedPeg {
	for (GSColorPeg *peg in self.colorPegs) if (peg.selected) return peg;
	return nil;
}

- (void)selectPeg:(GSColorPeg *)desiredSelection {
	for (GSColorPeg *peg in self.colorPegs) peg.selected = (peg == desiredSelection);
	self.colorEditorView.color = desiredSelection.color;
	
	[self.delegate gradientEditor:self pegSelectionChanged:desiredSelection];
}

#pragma mark Geometry
- (CGFloat)ratioForX:(CGFloat)x {
	// This is done with respect to the gradient editor view.
	return (x - self.gradientPreview.bounds.origin.x) / self.gradientPreview.bounds.size.width;
}

- (CGFloat)xForRatio:(CGFloat)ratio {
	return ratio * self.gradientPreview.bounds.size.width;
}

- (GSColorPeg *)colorPegClosestToX:(CGFloat)x {
	CGFloat threshold = 22.;
	
	GSColorPeg *closestPeg = nil;
	CGFloat distance = CGFLOAT_MAX;
	for (GSColorPeg *peg in self.colorPegs) {
		CGFloat thisDistance = fabs(x - [self xForRatio:peg.location]);
		if (thisDistance > threshold) continue;
		if (thisDistance < distance) {
			closestPeg = peg;
			distance = thisDistance;
		}
	}
	
	return closestPeg;
}

#pragma mark GSColorEditorViewDelegate
- (void)colorEditorChanged:(GSColorEditorView *)view {
	GSColorPeg *selectedPeg = [self selectedPeg];
	if (selectedPeg) {
		selectedPeg.color = view.color;
		[self updateDisplay];
	}
	
	[self.delegate gradientEditorChanged:self];
}

- (void)colorEditorDidBeginEditing:(GSColorEditorView *)view {
	[self.delegate gradientEditorDidBeginEditing:self];
}

- (void)colorEditorDidEndEditing:(GSColorEditorView *)view {
	[self.delegate gradientEditorDidEndEditing:self];
}

#ifdef GSGE_IOS
// These methods capture iOS touch events and pass them off to the cross-platform layer.
#pragma mark Events - iOS
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if (touches.count != 1) return;	// We don't use multi-touch capability.
	
	// Don't pick up touches outside the gradient preview view.
	CGPoint spotInGradient = [touches.anyObject locationInView:self.gradientPreview];
	if ((spotInGradient.y < 0) || (spotInGradient.y > self.gradientPreview.bounds.size.height)) return;
	
	if ([touches.anyObject tapCount] == 2) {
		[self tapClickCancelled];
		[self doubleTapClicked];
	}
	else {
		self.eventDidCreatePeg = NO;
		self.eventPeg = nil;
		[self tapClickStarted:spotInGradient];
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	[self tapClickMoved:[touches.anyObject locationInView:self.gradientPreview]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[self tapClickEnded:[touches.anyObject locationInView:self.gradientPreview]];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[self tapClickCancelled];
}
#endif

#pragma mark Events - Cross Platform Layer
- (void)tapClickStarted:(CGPoint)atPoint {
	self.eventStarted = YES;
	self.eventStartPoint = atPoint;
	
	[self.delegate gradientEditorDidBeginEditing:self];
	
	self.eventPeg = [self colorPegClosestToX:atPoint.x];
	if (self.eventPeg) {
		[self selectPeg:self.eventPeg];
		[self updatePegs];
	}
	else {
		// Add a new peg.
		GSGradient *g = [self gradient];
		CGFloat ratio = [self ratioForX:atPoint.x];
		ratio = MIN(ratio, 1);
		ratio = MAX(ratio, 0);
		
		GSColorPeg *newPeg = [GSColorPeg pegWithColor:[g interpolatedColorAtLocation:ratio] atLocation:ratio];
		self.eventDidCreatePeg = YES;
		[self addPeg:newPeg];
		[self selectPeg:newPeg];
		self.eventPeg = newPeg;
	}
}

- (void)tapClickMoved:(CGPoint)newPoint {
	if (!self.eventStarted) return;
	self.eventDidMove = YES;
	
	if (self.eventPeg) {
		if (fabs(newPoint.y - self.eventStartPoint.y) > GSGradientEditorDeleteThreshold) {
			if ([self.colorPegs containsObject:self.eventPeg] && (self.colorPegs.count > 2)) {
				[self removePeg:self.eventPeg];
			}
			else {
				[self movePeg:self.eventPeg toLocation:[self ratioForX:newPoint.x]];
			}
		}
		else {
			if (![self.colorPegs containsObject:self.eventPeg]) [self addPeg:self.eventPeg];
			[self movePeg:self.eventPeg toLocation:[self ratioForX:newPoint.x]];
		}
	}
}

- (void)tapClickEnded:(CGPoint)atPoint {
	self.eventStarted = NO;
	self.eventDidMove = NO;

	[self.delegate gradientEditorDidEndEditing:self];
}

- (void)tapClickCancelled {
	if (self.eventDidMove) {
		self.eventPeg.location = [self ratioForX:self.eventStartPoint.x];
	}
	if (self.eventDidCreatePeg) {
		[self removePeg:self.eventPeg];
	}
	
	self.eventStarted = NO;
	self.eventDidMove = NO;

	[self.delegate gradientEditorDidEndEditing:self];
}

- (void)doubleTapClicked {
	// Redistribute the pegs evenly.
	if (self.colorPegs.count < 2) return;
	
	for (NSInteger i = 0; i < self.colorPegs.count; i++) {
		[self movePegAtIndex:i toLocation:(CGFloat)i / (CGFloat)(self.colorPegs.count - 1)];
	}
}

@end
