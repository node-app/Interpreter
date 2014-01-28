//
//  NLConsoleViewController.m
//  Interpreter
//
//  Created by Sam Rijs on 1/28/14.
//  Copyright (c) 2014 Sam Rijs. All rights reserved.
//

#import "NLConsoleViewController.h"

@implementation NLConsoleViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    self.consoleText = @"";
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    self.console.text = self.consoleText;
}

- (void)log:(NSString *)string {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.consoleText = [self.consoleText stringByAppendingFormat:@"%@\n", string];
        self.console.text = self.consoleText;
    });
}

@end
