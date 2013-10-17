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
    void *callback, *error, *value;
};

@implementation NLContext {

    uv_loop_t *eventLoop;
    dispatch_queue_t dispatchQueue;

    NSMutableDictionary *requireCache;
    
}

- (void)augment {

    eventLoop     = [NLContext eventLoop];
    dispatchQueue = [NLContext dispatchQueue];

    requireCache  = [NLContext requireCache];

    self[@"global"]  = self.globalObject;

    self[@"process"] = [[NLProcess alloc] init];

    self[@"require"] = ^(NSString *module) {
        return [[NLContext currentContext] requireModule:module];
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

- (id)throwNewErrorWithMessage:(NSString *)message {
    self.exception = [JSValue valueWithNewErrorFromMessage:message inContext:self];
    return nil;
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

+ (JSValue *)createEventRequestOfType:(uv_req_type)type withCallback:(JSValue *)cb
                                   do:(void(^)(uv_loop_t *, void *, bool))task {
    
    NLContext *context = [NLContext currentContext];

    uv_req_t *req = malloc(uv_req_size(type));

    struct data *data = req->data = malloc(sizeof(struct data));
    data->callback = (void *)CFBridgingRetain(cb);
    data->error = nil;
    data->value = nil;

    bool async = ![cb isUndefined];

    task(context->eventLoop, req, async);

    dispatch_async(context->dispatchQueue, ^{
        uv_run(context->eventLoop, UV_RUN_DEFAULT);
    });

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

- (JSContext *)createContextForModule:(NSString *)module {
    
    NLContext *moduleContext = [[NLContext alloc] initWithVirtualMachine:self.virtualMachine];
    
    moduleContext.exceptionHandler = ^(JSContext *context, JSValue *error) {
        NSLog(@"%@: %@", module, error);
    };
    
    JSValue *moduleExports = [JSValue valueWithNewObjectInContext:moduleContext];
    JSValue *moduleModule  = [JSValue valueWithObject:[NSDictionary dictionaryWithObject:moduleExports forKey:@"exports"] inContext:moduleContext];
    
    moduleContext[@"exports"] = moduleExports;
    moduleContext[@"module"]  = moduleModule;
    
    return moduleContext;
    
}

- (JSValue *)requireModule:(NSString *)module {
    
    id cached = [requireCache objectForKey:module];
    
    if (cached != nil && [cached isKindOfClass:[JSValue class]]) {
        return cached;
    }
    
    JSContext *moduleContext;
    
    if (cached != nil && [cached isKindOfClass:[JSContext class]]) {
        moduleContext = cached;
    } else {
        moduleContext = [self createContextForModule:module];
        requireCache[module] = moduleContext;
    }
    
    NSString* path = [[NSBundle mainBundle] pathForResource:module
                                                     ofType:@"js"];
    
    NSString* content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    
    if (content != nil) {
        [moduleContext evaluateScript:content];
        JSValue *moduleValue = moduleContext[@"module"][@"exports"];
        requireCache[module] = moduleValue;
        return moduleValue;
    } else {
        NSString *error = [NSString stringWithFormat:@"Cannot find module '%@'", module];
        return [self throwNewErrorWithMessage:error];
    }
    
}

@end
