//
//  NLEditorViewController.m
//  NodelikeDemo
//
//  Created by Sam Rijs on 10/13/13.
//  Copyright (c) 2013 Sam Rijs. All rights reserved.
//

#import "NLEditorViewController.h"

#import "KOKeyboardRow.h"

#import "NLColor.h"
#import "NLContext.h"

@implementation NLEditorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.input = [NLTextView textViewForView:self.view];

    [self.view addSubview:self.input];

    [KOKeyboardRow applyToTextView:self.input];
    ((KOKeyboardRow *)self.input.inputAccessoryView).viewController = self;

}

- (void)viewDidAppear:(BOOL)animated {
    [self.input becomeFirstResponder];
}

- (void)execute {
    [self.masterViewController execute:self.input.text];
}

@end
