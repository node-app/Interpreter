//
//  The MIT License (MIT)
//
//  Copyright (c) 2013 Dominik Hauser
//  Copyright (c) 2013 Sam Rijs
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

#import "NLTextView.h"

#import "KOKeyboardRow.h"

static const float kCursorVelocity = 1.0f/8.0f;

@implementation NLTextView {

    NSRange       startRange;
    NSDictionary *highlightDef;
    NSDictionary *highlightTheme;
    
    UIPanGestureRecognizer *singleFingerPanRecognizer;
    UIPanGestureRecognizer *doubleFingerPanRecognizer;

}

#pragma mark Setup

- (void)setupWithViewController:(NLViewController *)viewController {

    [self setupGestureRecognizers];
    [self setupKeyboardWithViewController:viewController];
    [self setupHighlighting];

}

- (void)setupHighlighting {

    self.textStorage.delegate = self;
    highlightDef   = [NLTextView highlightDefinition];
    highlightTheme = [NLTextView highlightTheme];

}

- (void)setupKeyboardWithViewController:(NLViewController *)viewController {

    [KOKeyboardRow applyToTextView:self];
    ((KOKeyboardRow *)self.inputAccessoryView).viewController = viewController;
	[self becomeFirstResponder];

}

#pragma mark Syntax Highlighting

- (void)textStorageDidProcessEditing:(id)sender {

    NSRange paragaphRange = [self.textStorage.string paragraphRangeForRange: self.textStorage.editedRange];

    [self.textStorage removeAttribute:NSForegroundColorAttributeName range:paragaphRange];

    for (NSString* key in highlightDef) {

        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:[highlightDef objectForKey:key]
                                                                               options:NSRegularExpressionDotMatchesLineSeparators error:nil];

        [regex enumerateMatchesInString:self.textStorage.string options:0 range:paragaphRange
                             usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            [self.textStorage addAttribute:NSForegroundColorAttributeName value:[highlightTheme objectForKey:key] range:result.range];
        }];

    }

}

+ (NSDictionary *)highlightDefinition {
    
    NSString *path = [NSBundle.mainBundle pathForResource:@"Syntax" ofType:@"plist"];
    return [NSDictionary dictionaryWithContentsOfFile:path];
    
}

+ (NSDictionary *)highlightTheme {
    
    return @{@"text":                          [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1],
             @"background":                    [UIColor colorWithRed: 40.0/255 green: 43.0/255 blue: 52.0/255 alpha:1],
             @"comment":                       [UIColor colorWithRed: 72.0/255 green:190.0/255 blue:102.0/255 alpha:1],
             @"documentation_comment":         [UIColor colorWithRed: 72.0/255 green:190.0/255 blue:102.0/255 alpha:1],
             @"documentation_comment_keyword": [UIColor colorWithRed: 72.0/255 green:190.0/255 blue:102.0/255 alpha:1],
             @"string":                        [UIColor colorWithRed:230.0/255 green: 66.0/255 blue: 75.0/255 alpha:1],
             @"character":                     [UIColor colorWithRed:139.0/255 green:134.0/255 blue:201.0/255 alpha:1],
             @"number":                        [UIColor colorWithRed:139.0/255 green:134.0/255 blue:201.0/255 alpha:1],
             @"keyword":                       [UIColor colorWithRed:195.0/255 green: 55.0/255 blue:149.0/255 alpha:1],
             @"preprocessor":                  [UIColor colorWithRed:211.0/255 green:142.0/255 blue: 99.0/255 alpha:1],
             @"url":                           [UIColor colorWithRed: 35.0/255 green: 63.0/255 blue:208.0/255 alpha:1],
             @"attribute":                     [UIColor colorWithRed:103.0/255 green:135.0/255 blue:142.0/255 alpha:1],
             @"project":                       [UIColor colorWithRed:146.0/255 green:199.0/255 blue:119.0/255 alpha:1],
             @"other":                         [UIColor colorWithRed:  0.0/255 green:175.0/255 blue:199.0/255 alpha:1]};
    
}

#pragma mark Gestures

- (void)setupGestureRecognizers {

    singleFingerPanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(singleFingerPanHappend:)];
    singleFingerPanRecognizer.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:singleFingerPanRecognizer];
    
    doubleFingerPanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(doubleFingerPanHappend:)];
    doubleFingerPanRecognizer.minimumNumberOfTouches = 2;
    [self addGestureRecognizer:doubleFingerPanRecognizer];

}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {

    // Only accept horizontal pans for the code navigation to preserve correct scrolling behaviour.
    if (gestureRecognizer == singleFingerPanRecognizer || gestureRecognizer == doubleFingerPanRecognizer) {
        CGPoint translation = [gestureRecognizer translationInView:self];
        return fabsf(translation.x) > fabsf(translation.y);
    }

    return YES;

}

- (void)requireGestureRecognizerToFail:(UIGestureRecognizer *)gestureRecognizer {

    [singleFingerPanRecognizer requireGestureRecognizerToFail:gestureRecognizer];
    [doubleFingerPanRecognizer requireGestureRecognizerToFail:gestureRecognizer];

}

- (void)singleFingerPanHappend:(UIPanGestureRecognizer *)sender {

    if (sender.state == UIGestureRecognizerStateBegan) {
        startRange = self.selectedRange;
    }

    CGFloat cursorLocation = MAX(startRange.location + [sender translationInView:self].x * kCursorVelocity, 0);

    self.selectedRange = NSMakeRange(cursorLocation, 0);

}

- (void)doubleFingerPanHappend:(UIPanGestureRecognizer *)sender {

    if (sender.state == UIGestureRecognizerStateBegan) {
        startRange = self.selectedRange;
    }

    CGFloat cursorLocation = MAX(startRange.location + [sender translationInView:self].x * kCursorVelocity, 0);

    if (cursorLocation > startRange.location) {
        self.selectedRange = NSMakeRange(startRange.location, fabsf(startRange.location - cursorLocation));
    } else {
        self.selectedRange = NSMakeRange(cursorLocation, fabsf(startRange.location - cursorLocation));
    }

}

@end
