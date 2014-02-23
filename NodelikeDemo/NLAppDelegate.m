//
//  NLAppDelegate.m
//  NodelikeDemo
//
//  Created by Sam Rijs on 10/13/13.
//  Copyright (c) 2013 Sam Rijs. All rights reserved.
//

#import "NLAppDelegate.h"

#import "NLContext.h"

@implementation NLAppDelegate

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {

    NSString *script = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    
    if (script) {
        [NSNotificationCenter.defaultCenter postNotificationName:@"NLFileOpen" object:nil userInfo:@{@"script": script}];
    }

    return YES;
}

@end
