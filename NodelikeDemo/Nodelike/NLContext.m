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

struct data {
    void *callback, *error, *value;
};

@implementation NLContext {
    uv_loop_t *eventLoop;
    dispatch_queue_t dispatchQueue;
}

+ (uv_loop_t *)eventLoop {
    return uv_default_loop();
}

+ (dispatch_queue_t)dispatchQueue {
    static dispatch_queue_t queue = nil;
    static dispatch_once_t token = 0;
    dispatch_once(&token, ^{
        queue = dispatch_queue_create("eventLoop", DISPATCH_QUEUE_SERIAL);
    });
    return queue;
}

- (void)augment {

    eventLoop     = [NLContext eventLoop];
    dispatchQueue = [NLContext dispatchQueue];

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

+ (NLContext *)contextForEventRequest:(void *)req {
    return (NLContext *)[(__bridge JSValue *)(((struct data *)(((uv_req_t *)req)->data))->callback) context];
}

- (JSValue *)runEventRequest:(void(^)(uv_loop_t *loop, void *req, bool async))task
                      ofType:(uv_req_type)type withCallback:(JSValue *)cb {

    uv_req_t *req = malloc(uv_req_size(type));

    struct data *data = req->data = malloc(sizeof(struct data));
    data->callback = (void *)CFBridgingRetain(cb);

    bool async = ![cb isUndefined];

    task(eventLoop, req, async);

    dispatch_async(dispatchQueue, ^{
        uv_run(eventLoop, UV_RUN_DEFAULT);
    });

    if (!async) {

        JSValue *error = data->error != nil ? CFBridgingRelease(data->error) : nil;
        JSValue *value = data->value != nil ? CFBridgingRelease(data->value) : nil;

        free(data);

        if (error == nil) {
            return value;
        } else {
            self.exception = error;
        }

    }

    return nil;

}

- (void)finishEventRequestWithData:(void *)data_ error:(JSValue *)errorArg value:(JSValue *)valueArg {

    struct data *data = data_;

    JSValue *cb = CFBridgingRelease(data->callback);

    if (![cb isUndefined]) {

        free(data);
        [cb callWithArguments:@[errorArg, valueArg]];

    } else if ([errorArg isNull]) {

        data->error = nil;
        data->value = (void *)CFBridgingRetain(valueArg);

    } else {

        data->error = (void *)CFBridgingRetain(errorArg);
        data->value = nil;

    }

}

- (id)throwNewErrorWithMessage:(NSString *)message {
    self.exception = [JSValue valueWithNewErrorFromMessage:message inContext:self];
    return nil;
}

@end
