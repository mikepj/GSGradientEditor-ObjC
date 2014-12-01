GSGradientEditor
===========

This module provides a way to create and customize gradients.  There's also a view that can be used as an RGB color palette.

This module breaks MVC conventions a bit to make it more flexible to integrate in your own app.  GSGradientEditorView acts as both the view and the controller, while other classes in the module (GSColorPeg, etc) provide the model layer.  To integrate into your own app, just add a GSGradientEditorView to your heirarchy and set a delegate.

#### Requirements:
- ARC memory management

#### Future functionality:
- [ ] OS X support

#### Screenshot:
![](https://github.com/mikepj/GSGradientEditor/master/sample.png)

#### User Documentation
Tap to select each color peg.  Tap and drag to move a color peg.  Double tap in the gradient preview area to evenly distribute the color pegs.  Tap in an empty area to add a new color peg.  Drag a color peg off the gradient preview area to delete it.

#### Sample code:
```
#include "GSGradientEditor.h"

CGSize suggestedSize = [GSGradientEditorView suggestedViewSize];
GSGradientEditorView *gradientEditor = [[GSGradientEditorView alloc] initWithFrame:CGRectMake(0, 0, suggestedSize.width, suggestedSize.height)];
gradientEditor.delegate = self;
GSGradient *startingGradient = [[GSGradient alloc] initWithStartingColor:[UIColor colorWithRed:1. green:0 blue:0 alpha:1.]
															 endingColor:[UIColor colorWithRed:0 green:0 blue:1. alpha:1.]];
[gradientEditor setGradient:startingGradient];
[self.view addSubview:gradientEditor];

#pragma mark GSGradientEditorDelegate
- (void)gradientEditorChanged:(GSGradientEditorView *)view {
    GSGradient *gradient = [view gradient];
	// Do something with the gradient.
}

- (void)gradientEditor:(GSGradientEditorView *)view pegSelectionChanged:(GSColorPeg *)newSelection {
}

- (void)gradientEditorDidBeginEditing:(GSGradientEditorView *)view {
}

- (void)gradientEditorDidEndEditing:(GSGradientEditorView *)view {
}

```
