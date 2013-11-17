//
//  NLViewController.m
//  NodelikeDemo
//
//  Created by Sam Rijs on 10/13/13.
//  Copyright (c) 2013 Sam Rijs. All rights reserved.
//

#import "NLViewController.h"

#import "KOKeyboardRow.h"

#import "NLOutputViewController.h"

#import "Nodelike.h"

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

    UIColor *foreground = [UIColor blackColor];
    UIColor *background = [UIColor colorWithRed:163/255.0f green:232/255.0f blue:75/255.0f alpha:1.0f];
    
    self.navigationController.navigationBar.tintColor    = foreground;
    self.navigationController.navigationBar.barTintColor = background;
    self.navigationController.navigationBar.translucent  = NO;
    self.navigationController.toolbar.tintColor          = foreground;
    self.navigationController.toolbar.barTintColor       = background;

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"%@", _outputString);
    ((NLOutputViewController *)[segue destinationViewController]).outputString = _outputString;
}

- (void)output:(NSString *)message {
    NSLog(@"output %@", message);
    _outputString = message;
    [self performSegueWithIdentifier:@"display" sender:self];
}

- (void)execute {
    NSLog(@"execute %@", _input.text);
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
