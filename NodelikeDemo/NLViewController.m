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

@property NSMutableArray *log;

@property JSContext *context;

@end

@implementation NLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupStyle];
    
    __weak NLViewController *weakSelf = self;

    _appDelegate = [[UIApplication sharedApplication] delegate];

    _context = [[JSContext alloc] initWithVirtualMachine:[[JSVirtualMachine alloc] init]];

    [NLContext attachToContext:_context];
    
    self.log = [NSMutableArray new];

    _context.exceptionHandler = ^(JSContext *c, JSValue *e) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf error:[e toString]];
            NSLog(@"%@ stack: %@", e, [e valueForProperty:@"stack"]);
        });
    };

    _context[@"inspect"] = ^(JSValue *obj) {
        dispatch_async(dispatch_get_main_queue(), ^{
            SEJSONViewController *con = [SEJSONViewController new];
            [con setData:[obj toObject]];
            [weakSelf.navigationController pushViewController:con animated:YES];
        });
    };
    
    _context[@"console"] = @{@"log": ^(JSValue *thing) {
        [JSContext.currentArguments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [weakSelf.log addObject:[obj toObject]];
        }];
    }};

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
    [NLContext runEventLoop];
    if (![ret isUndefined]) {
        [self output:[ret toString]];
    }
    if ([self.log count]) {
        SEJSONViewController *con = [SEJSONViewController new];
        [con setData:[NSArray arrayWithArray:self.log]];
        [self.navigationController pushViewController:con animated:YES];
        [self.log removeAllObjects];
    }
}

- (IBAction)showDocu:(id)sender {
    PBWebViewController *docuViewController = [[PBWebViewController alloc] init];
    docuViewController.URL = [NSURL URLWithString:@"http://nodejs.org/docs/latest/api/"];
    [self.navigationController pushViewController:docuViewController animated:YES];
}

- (IBAction)showInfo:(id)sender {
    PBWebViewController *docuViewController = [[PBWebViewController alloc] init];
    docuViewController.URL = [NSURL URLWithString:@"http://nodeapp.org/?utm_source=interpreter&utm_medium=App&utm_campaign=info"];
    [self.navigationController pushViewController:docuViewController animated:YES];
}

@end
