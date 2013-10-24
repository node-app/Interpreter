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
    [KOKeyboardRow applyToTextView:_output];
    ((KOKeyboardRow *)_output.inputAccessoryView).viewController = self;
	[_output becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)execute {
    NSLog(@"execute");
    [_appDelegate execute:_output.text];
    _output.text = @"";
}

@end
