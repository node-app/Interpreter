//
//  NLEditorViewController.h
//  NodelikeDemo
//
//  Created by Sam Rijs on 10/13/13.
//  Copyright (c) 2013 Sam Rijs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NLMasterViewController.h"

#import "NLTextView.h"

@interface NLEditorViewController : UIViewController

@property NLMasterViewController *masterViewController;

@property IBOutlet NLTextView *input;

- (void) execute;

@end
