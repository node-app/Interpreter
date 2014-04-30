//
//  NLMasterViewController.h
//  Interpreter
//
//  Created by Sam Rijs on 1/28/14.
//  Copyright (c) 2014 Sam Rijs. All rights reserved.
//

#import "FHSegmentedViewController.h"

#import "NLContext.h"

@interface NLMasterViewController : FHSegmentedViewController

@property UIViewController *editorViewController;
@property UIViewController *consoleViewController;
@property UIViewController *documentationViewController;

@property NLContext *context;

@property UIBackgroundTaskIdentifier backgroundTask;

- (void)executeJS:(NSString *)code;

@end
