//
//  NLContext.m
//  NodelikeDemo
//
//  Created by Sam Rijs on 10/13/13.
//  Copyright (c) 2013 Sam Rijs. All rights reserved.
//

#import "NLContext.h"

#import "NLProcess.h"
#import "NLRequire.h"

@implementation NLContext

+ (dispatch_queue_t)dispatchQueue {
    static dispatch_queue_t queue = nil;
    static dispatch_once_t token = 0;
    dispatch_once(&token, ^{
        queue = dispatch_queue_create("eventLoop", DISPATCH_QUEUE_SERIAL);
    });
    return queue;
}

- (void)augment {
    
    _eventLoop = uv_default_loop();

    self[@"global"] = self.globalObject;

    self[@"process"] = [[NLProcess alloc] init];

    self[@"require"] = ^(NSString *module) {
        return [NLRequire require:module inContext:JSContext.currentContext];
    };

}

- (id)init {
    self = [super init];
    [self augment];
    return self;
}

- (id)initWithVirtualMachine:(JSVirtualMachine *)virtualMachine {
    self = [super initWithVirtualMachine:virtualMachine];
    [self augment];
    return self;
}

+ (NLContext *)currentContext {
    return (NLContext *)[super currentContext];
}

- (void)runEventLoop {
    dispatch_async([NLContext dispatchQueue], ^{
        uv_run(_eventLoop, UV_RUN_DEFAULT);
    });
}

- (int)runEventTask:(int)result {
    [self runEventLoop];
    return result;
}

- (id)throwNewErrorWithMessage:(NSString *)message {
    self.exception = [JSValue valueWithNewErrorFromMessage:message inContext:self];
    return nil;
}

@end
