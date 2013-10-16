//
//  NLBindingFilesystem.m
//  NodelikeDemo
//
//  Created by Sam Rijs on 10/13/13.
//  Copyright (c) 2013 Sam Rijs. All rights reserved.
//

#import "NLBindingFilesystem.h"

@implementation NLBindingFilesystem

- (id)init {

    self = [super init];

    _Stats = [JSValue valueWithNewObjectInContext:[JSContext currentContext]];
    _Stats[@"prototype"] = [JSValue valueWithNewObjectInContext:[JSContext currentContext]];

    return self;

}

- (id)binding {
    return self;
}

static void after(uv_fs_t* req) {

    NLContext *context = [NLContext contextForEventRequest:req];

    JSValue *errorArg = [JSValue valueWithNullInContext:context];
    JSValue *valueArg = [JSValue valueWithUndefinedInContext:context];

    if (req->result < 0) {

        errorArg = [JSValue valueWithNewErrorFromMessage:@"error" inContext:context];

    } else {

        switch (req->result) {
            case UV_FS_OPEN:
                valueArg = [JSValue valueWithInt32:req->result inContext:context];
                break;
            default: assert(0 && "Unhandled eio response");
        }

    }

    void *data = req->data;

    uv_fs_req_cleanup(req);
    
    [context finishEventRequestWithData:data error:errorArg value:valueArg];

}

#define CALL(fun, cb, ...)                                                                  \
    [[NLContext currentContext] runEventRequest:^(uv_loop_t *loop, void *req, bool async) { \
        uv_fs_ ## fun(loop, req, __VA_ARGS__, async ? after : nil);                         \
        if (!async) after(req);                                                             \
    } ofType:UV_FS withCallback:cb]

- (JSValue *)open:(NSString *)path flags:(NSNumber *)flags mode:(NSNumber *)mode callback:(JSValue *)cb {
    return CALL(open, cb, [path cStringUsingEncoding:NSUTF8StringEncoding], [flags intValue], [mode intValue]);
}

- (JSValue *)close:(NSNumber *)file callback:(JSValue *)cb {
    return CALL(close, cb, [file intValue]);
}

@end
