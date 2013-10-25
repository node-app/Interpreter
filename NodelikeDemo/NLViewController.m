//
//  NLViewController.m
//  NodelikeDemo
//
//  Created by Sam Rijs on 10/13/13.
//  Copyright (c) 2013 Sam Rijs. All rights reserved.
//

#import "NLViewController.h"

#import "KOKeyboardRow.h"

@interface NLViewController ()

@end

@implementation NLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _appDelegate = [[UIApplication sharedApplication] delegate];
    [KOKeyboardRow applyToTextView:_input];
    ((KOKeyboardRow *)_input.inputAccessoryView).viewController = self;
	[_input becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)execute {
    NSLog(@"execute");
    [_appDelegate execute:_input.text];
    _input.text = @"";
    _output.text = _appDelegate.outputText;
}

@end
