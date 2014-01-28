//
//  NLConsoleViewController.h
//  Interpreter
//
//  Created by Sam Rijs on 1/28/14.
//  Copyright (c) 2014 Sam Rijs. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NLMasterViewController.h"

@interface NLConsoleViewController : UIViewController

@property NLMasterViewController *masterViewController;

@property IBOutlet UITextView *console;

@property NSString *consoleText;

- (void)log:(NSString *)string;

@end
