//
//  NLBindingTimerWrap.m
//  NodelikeDemo
//
//  Created by Sam Rijs on 10/21/13.
//  Copyright (c) 2013 Sam Rijs. All rights reserved.
//

#import "NLBindingTimerWrap.h"

@implementation NLBindingTimerWrap

- (id)binding {
    
    JSValue *timer = [JSValue valueWithNewObjectInContext:[JSContext currentContext]];
    timer[@"prototype"] = [JSValue valueWithNewObjectInContext:[JSContext currentContext]];
    
    return @{@"Timer": timer};
}

@end
