//
//  NLViewController.m
//  NodelikeDemo
//
//  Created by Sam Rijs on 10/13/13.
//  Copyright (c) 2013 Sam Rijs. All rights reserved.
//

#import "NLViewController.h"

#import "KOKeyboardRow.h"
#import "CSNotificationView.h"

#import "NLColor.h"
#import "NLContext.h"

@interface NLViewController ()

@property UIViewController* outputViewController;
@property NSString *outputString;

@property NLContext *context;

@end

@implementation NLViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupStyle];

    _appDelegate = [[UIApplication sharedApplication] delegate];

    _context = [[NLContext alloc] initWithVirtualMachine:[[JSVirtualMachine alloc] init]];
    _context.exceptionHandler = ^(JSContext *c, JSValue *e) {
        NSLog(@"%@", e);
    };
    
    [KOKeyboardRow applyToTextView:_input];
    ((KOKeyboardRow *)_input.inputAccessoryView).viewController = self;
	[_input becomeFirstResponder];

}

- (void)setupStyle {

    self.navigationController.navigationBar.tintColor    = [NLColor greenColor];
    self.navigationController.navigationBar.barTintColor = [NLColor blackColor];
    self.navigationController.toolbar.tintColor          = [NLColor blackColor];
    self.navigationController.toolbar.barTintColor       = [[NLColor whiteColor] colorWithAlphaComponent:0.5];

    self.input.backgroundColor = [NLColor beigeColor];

}

- (void)output:(NSString *)message {
    [CSNotificationView showInViewController:self
                                       style:CSNotificationViewStyleSuccess
                                     message:message];
}

- (void)execute {
    JSValue *ret = [_context evaluateScript:_input.text];
    if (![ret isUndefined]) {
        [self output:[ret toString]];
    }
    _input.text = @"";
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
