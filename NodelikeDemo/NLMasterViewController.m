//
//  NLMasterViewController.m
//  Interpreter
//
//  Created by Sam Rijs on 1/28/14.
//  Copyright (c) 2014 Sam Rijs. All rights reserved.
//

#import "NLMasterViewController.h"

#import "NLEditorViewController.h"
#import "NLConsoleViewController.h"

#import "CSNotificationView.h"
#import "PBWebViewController.h"

#import "NLColor.h"

@interface NLMasterViewController ()

@end

@implementation NLMasterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{

    [super viewDidLoad];
    
    self.editorViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"editorViewController"];
    self.consoleViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"consoleViewController"];
    self.documentationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"documentationViewController"];
    
	[self setViewControllers:@[self.editorViewController, self.consoleViewController]];
    [self pushViewController:self.documentationViewController];
    
    [self setupStyle];
    
    __weak NLMasterViewController *weakSelf = self;
    
    _context = [[NLContext alloc] initWithVirtualMachine:[[JSVirtualMachine alloc] init]];
    
    [NLContext attachToContext:_context];
    
    _context.exceptionHandler = ^(JSContext *c, JSValue *e) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf error:[e toString]];
            NSLog(@"%@ stack: %@", e, [e valueForProperty:@"stack"]);
        });
    };
    
    id logger = ^(JSValue *thing) {
        [JSContext.currentArguments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSLog(@"log: %@", [obj toString]);
            [((NLConsoleViewController *)self.consoleViewController) log:[obj toString]];
        }];
    };
    _context[@"console"] = @{@"log": logger, @"error": logger};
    
    //[_context evaluateScript:@"process.env['NODE_DEBUG']='module'"];

}

- (void)setupStyle {
    
    //self.navigationController.navigationBar.tintColor    = [NLColor greenColor];
    //self.navigationController.navigationBar.barTintColor = [NLColor blackColor];
    self.navigationController.toolbar.tintColor          = [NLColor blackColor];
    self.navigationController.toolbar.barTintColor       = [[NLColor whiteColor] colorWithAlphaComponent:0.5];
    
}

- (void)executeJS:(NSString *)code {
    JSValue *ret = [_context evaluateScript:code];
    if (![ret isUndefined]) {
        [self output:[ret toString]];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        self.backgroundTask = [UIApplication.sharedApplication beginBackgroundTaskWithExpirationHandler:^{
            NSLog(@"beginBG called");
            [UIApplication.sharedApplication endBackgroundTask:self.backgroundTask];
            self.backgroundTask = UIBackgroundTaskInvalid;
        }];
        
        [NLContext runEventLoopSync];
        
        [UIApplication.sharedApplication endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;

    });

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

- (IBAction)execute:(id)sender {
    [self executeJS:((NLEditorViewController *)self.editorViewController).input.text];
}

- (IBAction)showInfo:(id)sender {
    PBWebViewController *docuViewController = [[PBWebViewController alloc] init];
    docuViewController.URL = [NSURL URLWithString:@"http://nodeapp.org/?utm_source=interpreter&utm_medium=App&utm_campaign=info"];
    [self.navigationController pushViewController:docuViewController animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
