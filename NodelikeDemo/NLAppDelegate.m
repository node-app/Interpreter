//
//  NLAppDelegate.m
//  NodelikeDemo
//
//  Created by Sam Rijs on 10/13/13.
//  Copyright (c) 2013 Sam Rijs. All rights reserved.
//

#import "NLAppDelegate.h"

#import "NLContext.h"

@implementation NLAppDelegate {
    NSString *scriptToLoad;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {

    NSString *script = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    
    if (script) {
        
        scriptToLoad = script;

        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Open File"
                              message:@"You are about to load a file into the editor. This will clear your current script."
                              delegate:self
                              cancelButtonTitle:@"Cancel"
                              otherButtonTitles:@"OK",
                              nil];
        [alert show];

    }

    return YES;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"OK"]) {
        [NSNotificationCenter.defaultCenter postNotificationName:@"NLFileOpen" object:nil userInfo:@{@"script": scriptToLoad}];
    }
}

@end
