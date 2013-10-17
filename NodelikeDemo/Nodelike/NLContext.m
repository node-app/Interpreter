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

#pragma mark Event Handling

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

+ (void)finishEventRequest:(void *)req do:(void (^)(NLContext *, JSValue **, JSValue **))task {

    NLContext *context = [NLContext contextForEventRequest:req];

    JSValue *errorArg = [JSValue valueWithNullInContext:context];
    JSValue *valueArg = [JSValue valueWithUndefinedInContext:context];

    struct data *data = ((uv_req_t *)req)->data;
    
    task(context, &errorArg, &valueArg);
    
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

- (JSValue *)errorForEventRequestError:(int)error {
    
    NSString *msg = [NSString stringWithCString:uv_strerror(error) encoding:NSUTF8StringEncoding];;
    return [JSValue valueWithNewErrorFromMessage:msg inContext:self];

}

#pragma mark Module Loading

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
