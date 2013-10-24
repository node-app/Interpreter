//
//  SwipeButton.m
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

#import "KOSwipeButton.h"
#import "KOKeyboardRow.h"

@interface KOSwipeButton ()

@property (nonatomic, retain) NSMutableArray *labels;
@property (nonatomic, assign) CGPoint touchBeginPoint;
@property (nonatomic, retain) UILabel *selectedLabel;
@property (nonatomic, retain) UIImageView *bgView;
@property (nonatomic, retain) UIImageView *foregroundView;
@property (nonatomic, assign) BOOL trackPoint;
@property (nonatomic, assign) BOOL tabButton;
@property (nonatomic, retain) NSDate *firstTapDate;
@property (nonatomic, assign) BOOL selecting;
@property (nonatomic, retain) UIImage *blueImage;
@property (nonatomic, retain) UIImage *pressedImage;
@property (nonatomic, retain) UIImage *blueFgImage;
@property (nonatomic, retain) UIImage *pressedFgImage;

@end

#define TIME_INTERVAL_FOR_DOUBLE_TAP 0.4

@implementation KOSwipeButton

@synthesize labels, touchBeginPoint, selectedLabel, delegate, bgView, trackPoint, tabButton, selecting, firstTapDate, blueImage, pressedImage, foregroundView, blueFgImage, pressedFgImage;

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    UIImage *bgImg1 = [[UIImage imageNamed:@"key.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 9, 0, 9)];
    UIImage *bgImg2 = [[UIImage imageNamed:@"key-pressed.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 9, 0, 9)];
    bgView = [[UIImageView alloc] initWithFrame:self.bounds];
    [bgView setImage:bgImg1];
    [bgView setHighlightedImage:bgImg2];
    bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:bgView];
    
    int labelWidth = 20;
    int labelHeight = 20;
    int leftInset = 9;
    int rightInset = 9;
    int topInset = 3;
    int bottomInset = 8;
    
    self.labels = [[NSMutableArray alloc] init];
    
    UIFont *f = [UIFont systemFontOfSize:15];
    
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(leftInset, topInset, labelWidth, labelHeight)];
    l.textAlignment = UITextAlignmentLeft;
    l.text = @"1";
    l.font = f;
    [self addSubview:l];
    [l setHighlightedTextColor:[UIColor blueColor]];
    l.backgroundColor = [UIColor clearColor];
    [labels addObject:l];
    
    l = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - labelWidth - rightInset, topInset, labelWidth, labelHeight)];
    l.textAlignment = UITextAlignmentRight;
    l.text = @"2";
    l.font = f;
    l.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self addSubview:l];
    [l setHighlightedTextColor:[UIColor blueColor]];
    l.backgroundColor = [UIColor clearColor];
    [labels addObject:l];
    
    l = [[UILabel alloc] initWithFrame:CGRectIntegral(CGRectMake((self.frame.size.width - labelWidth - leftInset - rightInset) / 2 + leftInset, (self.frame.size.height - labelHeight - topInset - bottomInset) / 2 + topInset, labelWidth, labelHeight))];
    l.textAlignment = UITextAlignmentCenter;
    l.text = @"3";
    l.font = f;
    l.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:l];
    [l setHighlightedTextColor:[UIColor blueColor]];
    l.backgroundColor = [UIColor clearColor];
    [labels addObject:l];
    
    l = [[UILabel alloc] initWithFrame:CGRectMake(leftInset, (self.frame.size.height - labelHeight - bottomInset), labelWidth, labelHeight)];
    l.textAlignment = UITextAlignmentLeft;
    l.text = @"4";
    l.font = f;
    [self addSubview:l];
    [l setHighlightedTextColor:[UIColor blueColor]];
    l.backgroundColor = [UIColor clearColor];
    [labels addObject:l];
    
    l = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - labelWidth - rightInset, (self.frame.size.height - labelHeight - bottomInset), labelWidth, labelHeight)];
    l.textAlignment = UITextAlignmentRight;
    l.text = @"5";
    l.font = f;
    l.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self addSubview:l];
    [l setHighlightedTextColor:[UIColor blueColor]];
    l.backgroundColor = [UIColor clearColor];
    [labels addObject:l];
    
    firstTapDate = [[NSDate date] dateByAddingTimeInterval:-1];
    
    return self;
}

- (void)setKeys:(NSString *)newKeys
{
    for (int i = 0; i < MIN(newKeys.length, 5); i++) {
        [[labels objectAtIndex:i] setText:[newKeys substringWithRange:NSMakeRange(i, 1)]];
        
        if ([[newKeys substringToIndex:1] isEqualToString:@"◉"] |
            [[newKeys substringToIndex:1] isEqualToString:@"T"]) {
            
            trackPoint = [[newKeys substringToIndex:1] isEqualToString:@"◉"];
            tabButton = [[newKeys substringToIndex:1] isEqualToString:@"T"];
            
            if (i != 2)
                [[labels objectAtIndex:i] setHidden:YES];
            else {
                if (trackPoint) {
                    [[labels objectAtIndex:i] setHidden:YES];
                    
                    [[labels objectAtIndex:i] setFont:[UIFont systemFontOfSize:20]];
                    blueImage = [UIImage imageNamed:@"key-blue.png"];
                    pressedImage = [UIImage imageNamed:@"key-pressed.png"];
                    
                    UIImage *bgImg1 = [UIImage imageNamed:@"hal-black.png"];
                    UIImage *bgImg2 = [UIImage imageNamed:@"hal-blue.png"];
                    blueFgImage = [UIImage imageNamed:@"hal-white.png"];
                    pressedFgImage = bgImg2;
                    foregroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 19, 19)];
                    foregroundView.frame = CGRectMake((int)((self.frame.size.width - foregroundView.frame.size.width) / 2), (int)((self.frame.size.height - foregroundView.frame.size.height) / 2), 19, 19);
                    [foregroundView setImage:bgImg1];
                    [foregroundView setHighlightedImage:bgImg2];
                    foregroundView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
                    [self addSubview:foregroundView];

                } else {
                    [[labels objectAtIndex:i] setText:@"TAB"];
                    [[labels objectAtIndex:i] setFrame:self.bounds];
                }
            }
        }
    }
}

- (void)selectLabel:(int)idx
{
    selectedLabel = nil;
    
    for (int i = 0; i < labels.count; i++) {
        UILabel *l = [labels objectAtIndex:i];
        l.highlighted = (idx == i);
        
        if (idx == i)
            selectedLabel = l;
    }
    
    bgView.highlighted = selectedLabel != nil;
    foregroundView.highlighted = selectedLabel != nil;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *t = [touches anyObject];
    touchBeginPoint = [t locationInView:self];
    
    if (trackPoint) {
        if (fabs([firstTapDate timeIntervalSinceNow]) < TIME_INTERVAL_FOR_DOUBLE_TAP) {
            bgView.highlightedImage = blueImage;
            foregroundView.highlightedImage = blueFgImage;
            selecting = YES;
        } else {
            bgView.highlightedImage = pressedImage;
            foregroundView.highlightedImage = pressedFgImage;
            selecting = NO;
        }
        firstTapDate = [NSDate date];
        
        [delegate trackPointStarted];
    }
    
    [self selectLabel:2];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *t = [touches anyObject];
    CGPoint touchMovePoint = [t locationInView:self];
    
    CGFloat xdiff = touchBeginPoint.x - touchMovePoint.x;
    CGFloat ydiff = touchBeginPoint.y - touchMovePoint.y;
    CGFloat distance = sqrt(xdiff * xdiff + ydiff * ydiff);
    
    if (trackPoint) {
        [delegate trackPointMovedX:xdiff Y:ydiff selecting:selecting];
        return;
    }
    
    if (distance > 250) {
        [self selectLabel:-1];
    } else if (!tabButton && (distance > 20)) {
        CGFloat angle = atan2(xdiff, ydiff);
        
        if (angle >= 0 && angle < M_PI_2) {
            [self selectLabel:0];
        } else if (angle >= 0 && angle >= M_PI_2) {
            [self selectLabel:3];
        } else if (angle < 0 && angle > -M_PI_2) {
            [self selectLabel:1];
        } else if (angle < 0 && angle <= -M_PI_2) {
            [self selectLabel:4];
        }
    } else {
        [self selectLabel:2];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (selectedLabel != nil) {
        if (tabButton) {
            [delegate insertText:@"\t"];
        } else if (! trackPoint) {
            NSString *textToInsert = selectedLabel.text;
            [delegate insertText:textToInsert];
        }
    }
    
    [self selectLabel:-1];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self selectLabel:-1];
}

@end
