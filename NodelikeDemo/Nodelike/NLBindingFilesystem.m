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

    [NLContext finishEventRequest:req do:
     ^(NLContext *context) {

         if (req->result < 0) {

             [NLContext setError:[context errorForEventRequestError:req->result] forEventRequest:req];

         } else {

             switch (req->result) {
                 case UV_FS_OPEN:
                     [NLContext setValue:[JSValue valueWithInt32:req->result inContext:context] forEventRequest:req];
                     break;
                 default: assert(0 && "Unhandled eio response");
             }

         }

         uv_fs_req_cleanup(req);

     }];

}

#define CALL(fun, cb, ...)                                          \
    [NLContext createEventRequestOfType:UV_FS withCallback:cb do:   \
     ^(uv_loop_t *loop, void *req, bool async) {                    \
        uv_fs_ ## fun(loop, req, __VA_ARGS__, async ? after : nil); \
        if (!async) after(req);                                     \
    }]

- (JSValue *)open:(NSString *)path flags:(NSNumber *)flags mode:(NSNumber *)mode callback:(JSValue *)cb {
    return CALL(open, cb, [path cStringUsingEncoding:NSUTF8StringEncoding], [flags intValue], [mode intValue]);
}

- (JSValue *)close:(NSNumber *)file callback:(JSValue *)cb {
    return CALL(close, cb, [file intValue]);
}

@end
