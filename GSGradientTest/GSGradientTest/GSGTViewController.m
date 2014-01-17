//
//  GSGTViewController.m
//  GSGradientTest
//
//  Created by Mike Piatek-Jimenez on 1/17/14.
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

#import "GSGTViewController.h"

@interface GSGTViewController ()

@end

@implementation GSGTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	NSArray *colorArray = @[[UIColor colorWithRed:0.5 green:0    blue:1. alpha:1.],
 						    [UIColor colorWithRed:0   green:0    blue:1. alpha:1.],
						    [UIColor colorWithRed:0   green:0.75 blue:1. alpha:1.],
						    [UIColor colorWithRed:0   green:1.   blue:0  alpha:1.],
						    [UIColor colorWithRed:1.  green:1.   blue:0  alpha:1.],
						    [UIColor colorWithRed:1.  green:0    blue:0  alpha:1.]];
	
	[self.gradientEditor setGradient:[[GSGradient alloc] initWithColors:colorArray]];
	self.gradientEditor.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark GSGradientEditorDelegate
- (void)gradientEditorChanged:(GSGradientEditorView *)view {
    GSGradient *gradient = [view gradient];
	// Do something with the gradient.
	NSLog(@"Gradient changed: %@", gradient);
}

- (void)gradientEditor:(GSGradientEditorView *)view pegSelectionChanged:(GSColorPeg *)newSelection {
}

- (void)gradientEditorDidBeginEditing:(GSGradientEditorView *)view {
}

- (void)gradientEditorDidEndEditing:(GSGradientEditorView *)view {
}

@end
