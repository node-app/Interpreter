//
//  NLContext.m
//  NodelikeDemo
//
//  Created by Sam Rijs on 10/13/13.
//  Copyright (c) 2013 Sam Rijs. All rights reserved.
//

#import "NLContext.h"

#import "NLProcess.h"

struct data {
    void *callback, *error, *value, *after;
};

@implementation NLContext {

    dispatch_queue_t dispatchQueue;

    NSMutableDictionary *requireCache;
    
}

#pragma mark - JSContext

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

- (JSValue *)evaluateScript:(NSString *)script {
    JSValue *val = [super evaluateScript:script];
    [self runEventLoop];
    return val;
}

#pragma mark - Scope Setup

- (void)augment {

    _eventLoop    = [NLContext eventLoop];
    dispatchQueue = [NLContext dispatchQueue];

    requireCache  = [NLContext requireCache];

    self[@"global"]  = self.globalObject;

    self[@"process"] = [[NLProcess alloc] init];

    self[@"require"] = ^(NSString *module) {
        return [[NLContext currentContext] requireModule:module];
    };
    
    self[@"log"] = ^(id msg) {
        NSLog(@"%@", msg);
    };

}

#pragma mark - Event Handling

+ (uv_loop_t *)eventLoop {
    return uv_default_loop();
}

+ (dispatch_queue_t)dispatchQueue {
    static dispatch_queue_t queue;
    static dispatch_once_t token = 0;
    dispatch_once(&token, ^{
        queue = dispatch_queue_create("eventLoop", DISPATCH_QUEUE_SERIAL);
    });
    return queue;
}

+ (NLContext *)contextForEventRequest:(void *)req {
    return (NLContext *)[(__bridge JSValue *)(((struct data *)(((uv_req_t *)req)->data))->callback) context];
}

- (void)runEventLoop {
    dispatch_async(self->dispatchQueue, ^{
        uv_run(_eventLoop, UV_RUN_DEFAULT);
    });
}

+ (JSValue *)createEventRequestOfType:(uv_req_type)type withCallback:(JSValue *)cb
                                   do:(void(^)(uv_loop_t *, void *, bool))task
                                 then:(void(^)(void *, NLContext *))after {
    
    NLContext *context = [NLContext currentContext];

    uv_req_t *req = malloc(uv_req_size(type));

    struct data *data = req->data = malloc(sizeof(struct data));
    data->callback = (void *)CFBridgingRetain(cb);
    data->error = nil;
    data->value = nil;
    data->after = (void *)CFBridgingRetain(after);

    bool async = ![cb isUndefined];

    task(context.eventLoop, req, async);

    if (!async) {

        JSValue *error = data->error != nil ? CFBridgingRelease(data->error) : nil;
        JSValue *value = data->value != nil ? CFBridgingRelease(data->value) : nil;

        free(data);

        if (error == nil) {
            return value;
        } else {
            context.exception = error;
        }

    }

    return nil;

}

+ (void)finishEventRequest:(void *)req do:(void (^)(NLContext *))task {

    NLContext *context = [NLContext contextForEventRequest:req];

    struct data *data = ((uv_req_t *)req)->data;

    task(context);
    
    JSValue *cb    = CFBridgingRelease(data->callback);
    JSValue *error = data->error != nil ? CFBridgingRelease(data->error) : [JSValue valueWithNullInContext:context];
    JSValue *value = data->value != nil ? CFBridgingRelease(data->value) : [JSValue valueWithUndefinedInContext:context];
    
    if (![cb isUndefined]) {
        
        free(data);
        [cb callWithArguments:@[error, value]];
        
    } else if ([error isNull]) {
        
        data->error = nil;
        data->value = (void *)CFBridgingRetain(value);
        
    } else {
        
        data->error = (void *)CFBridgingRetain(error);
        data->value = nil;
        
    }
    
}

- (void)callSuccessfulEventRequest:(void *)req {
    struct data *data = ((uv_req_t *)req)->data;
    if (data->after != nil) {
        ((void (^)(void*, NLContext *))CFBridgingRelease(data->after))(req, self);
    }
}

- (void)setErrorCode:(int)error forEventRequest:(void *)req {
    NSString *msg = [NSString stringWithCString:uv_strerror(error) encoding:NSUTF8StringEncoding];
    [self setError:[JSValue valueWithNewErrorFromMessage:msg inContext:self] forEventRequest:req];
}

- (void)setError:(JSValue *)error forEventRequest:(void *)req {
    ((struct data *)(((uv_req_t *)req)->data))->error = (void *)CFBridgingRetain(error);
}

- (void)setValue:(JSValue *)value forEventRequest:(void *)req {
    ((struct data *)(((uv_req_t *)req)->data))->value = (void *)CFBridgingRetain(value);
}

#pragma mark - Module Loading

+ (NSMutableDictionary *)requireCache {
    static NSMutableDictionary *cache;
    static dispatch_once_t token = 0;
    dispatch_once(&token, ^{
        cache = [[NSMutableDictionary alloc] init];
    });
    return cache;
}

- (JSValue *)requireModule:(NSString *)module {
    
    JSValue *cached = [requireCache objectForKey:module];
    
    if (cached != nil) {
        return cached;
    }
    
    NSString* path = [[NSBundle mainBundle] pathForResource:module
                                                     ofType:@"js"];
    
    NSString* content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    
    if (content == nil) {
        NSString *error = [NSString stringWithFormat:@"Cannot find module '%@'", module];
        self.exception = [JSValue valueWithNewErrorFromMessage:error inContext:self];
        return nil;
    }

    NSString *template = @"(function (exports, require, module, __filename, __dirname) {%@\n});";
    NSString *source = [NSString stringWithFormat:template, content];

    JSValue *fn = [self evaluateScript:source];
    
    JSValue *exports = [JSValue valueWithNewObjectInContext:self];
    JSValue *modulev = [JSValue valueWithNewObjectInContext:self];
    modulev[@"exports"] = exports;

    [fn callWithArguments:@[exports, self[@"require"], modulev]];

    JSValue *moduleValue = modulev[@"exports"];

    requireCache[module] = moduleValue;

    return moduleValue;
    
}

@end
