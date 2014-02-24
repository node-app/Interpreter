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
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    [self.view addSubview:self.input];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
      [KOKeyboardRow applyToTextView:self.input];
      ((KOKeyboardRow *)self.input.inputAccessoryView).viewController = self;
    }
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(fileOpenTriggered:) name:@"NLFileOpen" object:nil];

}

- (void)viewDidAppear:(BOOL)animated {
    [self.input becomeFirstResponder];
}

- (void)fileOpenTriggered:(NSNotification*)notification {
    self.input.text = notification.userInfo[@"script"];
}

@end
