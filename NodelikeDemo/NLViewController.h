//
//  NLViewController.h
//  NodelikeDemo
//
//  Created by Sam Rijs on 10/13/13.
//  Copyright (c) 2013 Sam Rijs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NLAppDelegate.h"

#import "PBWebViewController.h"

@interface NLViewController : UIViewController

@property NLAppDelegate *appDelegate;

@property IBOutlet UITextView *input;
@property IBOutlet UITextView *output;

- (void) execute;

- (IBAction)showDocu:(id)sender;

@end
