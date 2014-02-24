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

#import "CYRToken.h"

@implementation NLTextView

+ (instancetype)textViewForView:(UIView *)view {
    CGRect frame = view.frame;
    frame.size.height -= 64;
    return [[self alloc] initWithFrame:frame];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    self.gutterBackgroundColor = [UIColor clearColor];
    self.gutterLineColor       = [UIColor clearColor];

    self.font = [UIFont fontWithName:@"Menlo" size:14.0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrame:) name:UIKeyboardDidChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    self.highlightDefinition = [NLTextView defaultHighlightDefinition];
    self.highlightTheme      = [NLTextView defaultHighlightTheme];
    
    NSMutableArray *tokens = [NSMutableArray new];
    [self.highlightDefinition enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [tokens addObject:[CYRToken tokenWithName:key expression:obj
                                       attributes:@{NSForegroundColorAttributeName:self.highlightTheme[key]}]];
    }];
    self.tokens = tokens;

    return self;
}


- (void)keyboardWillShow:(NSNotification *)notification {
    [self moveTextViewForKeyboard:notification up:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [self moveTextViewForKeyboard:notification up:NO];
}

- (void)keyboardDidChangeFrame:(NSNotification *)notification {
    CGRect keyboardEndFrame, newFrame, keyboardFrame;
    [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    newFrame      = self.superview.bounds;
    keyboardFrame = [self.superview convertRect:keyboardEndFrame toView:nil];
    newFrame.size.height -= keyboardFrame.size.height;
    self.frame = newFrame;
}

- (void)orientationChanged:(NSNotification *)notification {
    self.frame = self.superview.bounds;
}

- (void)moveTextViewForKeyboard:(NSNotification* )notification up:(BOOL)up {
    NSDictionary* userInfo = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey]    getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]          getValue:&keyboardEndFrame];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    CGRect newFrame = self.frame;
    CGRect keyboardFrame = [self.superview convertRect:keyboardEndFrame toView:nil];
    newFrame.size.height -= keyboardFrame.size.height * (up?1:-1);
    self.frame = newFrame;
    
    [UIView commitAnimations];
}

+ (NSDictionary *)defaultHighlightDefinition {
    
    NSString *path = [NSBundle.mainBundle pathForResource:@"Syntax" ofType:@"plist"];
    return [NSDictionary dictionaryWithContentsOfFile:path];
    
}

+ (NSDictionary *)defaultHighlightTheme {
    
    return @{//@"text":                          [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1],
             //@"background":                    [UIColor colorWithRed: 40.0/255 green: 43.0/255 blue: 52.0/255 alpha:1],
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

@end
