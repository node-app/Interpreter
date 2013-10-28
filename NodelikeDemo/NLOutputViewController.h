//
//  NLOutputViewController.h
//  NodelikeDemo
//
//  Created by Sam Rijs on 10/28/13.
//  Copyright (c) 2013 Sam Rijs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NLOutputViewController : UIViewController

@property NSString *outputString;

@property IBOutlet UITextView *outputView;

- (IBAction)close:(id)sender;

@end
