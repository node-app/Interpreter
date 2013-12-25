//
//  NLViewController.m
//  NodelikeDemo
//
//  Created by Sam Rijs on 10/13/13.
//  Copyright (c) 2013 Sam Rijs. All rights reserved.
//

#import "NLViewController.h"

#import "CSNotificationView.h"
#import "SEJSONViewController.h"

#import "KOKeyboardRow.h"

#import "NLColor.h"
#import "NLContext.h"

@interface NLViewController ()

@property UIViewController* outputViewController;
@property NSString *outputString;

@property NLContext *context;

@end

@implementation NLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupStyle];
    
    __weak NLViewController *weakSelf = self;

    _appDelegate = [[UIApplication sharedApplication] delegate];

    _context = [[NLContext alloc] initWithVirtualMachine:[[JSVirtualMachine alloc] init]];
    _context.exceptionHandler = ^(JSContext *c, JSValue *e) {
        [weakSelf error:[e toString]];
        NSLog(@"%@ stack: %@", e, [e valueForProperty:@"stack"]);
    };

    _context[@"inspect"] = ^(JSValue *obj) {
        SEJSONViewController *con = [SEJSONViewController new];
        [con setData:[obj toObject]];
        [weakSelf.navigationController pushViewController:con animated:YES];
    };

    [KOKeyboardRow applyToTextView:self.input];
    ((KOKeyboardRow *)self.input.inputAccessoryView).viewController = self;

}

- (void)viewDidAppear:(BOOL)animated {
    [self.input becomeFirstResponder];
}

- (void)setupStyle {

    self.navigationController.navigationBar.tintColor    = [NLColor greenColor];
    self.navigationController.navigationBar.barTintColor = [NLColor blackColor];
    self.navigationController.toolbar.tintColor          = [NLColor blackColor];
    self.navigationController.toolbar.barTintColor       = [[NLColor whiteColor] colorWithAlphaComponent:0.5];

    self.input.backgroundColor = [NLColor beigeColor];
    self.input.inputView.backgroundColor = [NLColor beigeColor];

}

- (void)output:(NSString *)message {
    [CSNotificationView showInViewController:self
                                       style:CSNotificationViewStyleSuccess
                                     message:message];
}

- (void)error:(NSString *)message {
    [CSNotificationView showInViewController:self
                                       style:CSNotificationViewStyleError
                                     message:message];
}

- (void)execute {
    JSValue  *ret = [_context evaluateScript:self.input.text];
    if (![ret isUndefined]) {
        [self output:[ret toString]];
    }
    self.input.text = @"";
}

- (IBAction)showDocu:(id)sender {
    PBWebViewController *docuViewController = [[PBWebViewController alloc] init];
    docuViewController.URL = [NSURL URLWithString:@"http://nodejs.org/docs/latest/api/"];
    [self.navigationController pushViewController:docuViewController animated:YES];
}

- (IBAction)showInfo:(id)sender {
    PBWebViewController *docuViewController = [[PBWebViewController alloc] init];
    docuViewController.URL = [NSURL URLWithString:@"http://nodeapp.org"];
    [self.navigationController pushViewController:docuViewController animated:YES];
}

@end
