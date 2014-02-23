//
//  ExtraKeyboardRow.m
//  KeyboardTest
//
//  Created by Kuba on 28.06.12.
//  Copyright (c) 2012 Adam Horacek, Kuba Brecka
//
//  Website: http://www.becomekodiak.com/
//  github: http://github.com/adamhoracek/KOKeyboard
//	Twitter: http://twitter.com/becomekodiak
//  Mail: adam@becomekodiak.com, kuba@becomekodiak.com
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import "KOKeyboardRow.h"
#import "KOSwipeButton.h"

#import "NLColor.h"

@interface KOKeyboardRow ()

@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, assign) CGRect startLocation;

@end

@implementation KOKeyboardRow

@synthesize textView, startLocation;

+ (void)applyToTextView:(UITextView *)t
{
    int barHeight = 46;
    int barWidth = 768;
    
    int buttonCount = 1;
    int buttonHeight = 40;
    NSString *keys = @"TTTTT";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        buttonCount  = 11;
        barHeight    = 72;
        buttonHeight = 60;
        keys = @"()\"[]{}'<>\\/$´`~^|€£-+=%*◉◉◉◉◉!?#@&_:;,.1203467589TTTTT";
    }
    
    KOKeyboardRow *v = [[KOKeyboardRow alloc] initWithFrame:CGRectMake(0, 0, barWidth, barHeight)];
    v.backgroundColor = [NLColor blackColor];//[UIColor colorWithRed:240/255. green:240/255. blue:240/255. alpha:1];
    v.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    v.textView = t;
    
    int leftMargin = 3;
    int topMargin = 1;
    int buttonSpacing = 6;
    int buttonWidth = (barWidth - 2 * leftMargin - (buttonCount - 1) * buttonSpacing) / buttonCount;
    leftMargin = (barWidth - buttonWidth * buttonCount - buttonSpacing * (buttonCount - 1)) / 2;
    
    for (int i = 0; i < buttonCount; i++) {
        KOSwipeButton *b = [[KOSwipeButton alloc] initWithFrame:CGRectMake(leftMargin + i * (buttonSpacing + buttonWidth), topMargin + (barHeight - buttonHeight) / 2, buttonWidth, buttonHeight)];
        b.keys = [keys substringWithRange:NSMakeRange(i * 5, 5)];
        b.delegate = v;
        b.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [v addSubview:b];
    }
    
    t.inputAccessoryView = v;
}

- (void)insertText:(NSString *)text
{
    [textView insertText:text];
} 

- (void)trackPointStarted
{
    startLocation = [textView caretRectForPosition:textView.selectedTextRange.start];
}

- (void)trackPointMovedX:(int)xdiff Y:(int)ydiff selecting:(BOOL)selecting
{
    CGRect loc = startLocation;    
    
    loc.origin.y -= textView.contentOffset.y;
    
    UITextPosition *p1 = [textView closestPositionToPoint:loc.origin];
    
    loc.origin.x -= xdiff;
    loc.origin.y -= ydiff;
    
    UITextPosition *p2 = [textView closestPositionToPoint:loc.origin];
    
    if (!selecting) {
        p1 = p2;
    }
    UITextRange *r = [textView textRangeFromPosition:p1 toPosition:p2];
    
    textView.selectedTextRange = r;
}

@end
