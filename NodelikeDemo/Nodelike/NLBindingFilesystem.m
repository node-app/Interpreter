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

static void after(uv_fs_t* req) {
    [NLContext finishEventRequest:req do:
     ^(NLContext *context) {
         if (req->result < 0) {
             [context setErrorCode:req->result forEventRequest:req];
         } else {
             [context callSuccessfulEventRequest:req];
         }
         uv_fs_req_cleanup(req);
     }];
}

#define CALL(fun, cb, ...)                                          \
    NLContext createEventRequestOfType:UV_FS withCallback:cb do:    \
     ^(uv_loop_t *loop, void *req, bool async) {                    \
        uv_fs_ ## fun(loop, req, __VA_ARGS__, async ? after : nil); \
        if (!async) after(req);                                     \
    } then:

- (JSValue *)open:(NSString *)path flags:(NSNumber *)flags mode:(NSNumber *)mode callback:(JSValue *)cb {
    return [CALL(open, cb, [path cStringUsingEncoding:NSUTF8StringEncoding], [flags intValue], [mode intValue])
            ^(void *req_, NLContext *context) {
                uv_fs_t *req = req_;
                [context setValue:[JSValue valueWithInt32:req->result inContext:context] forEventRequest:req];
            }];
}

- (JSValue *)close:(NSNumber *)file callback:(JSValue *)cb {
    return [CALL(close, cb, [file intValue]) ^(void *req_, NLContext *context) {
        
    }];
}

- (JSValue *)readDir:(NSString *)path callback:(JSValue *)cb {
    return [CALL(readdir, cb, [path cStringUsingEncoding:NSUTF8StringEncoding], 0)
            ^(void *req_, NLContext *context) {
                uv_fs_t *req = req_;
                char *namebuf = req->ptr;
                int i, nnames = req->result;
                JSValue *names = [JSValue valueWithNewArrayInContext:context];
                for (i = 0; i < nnames; i++) {
                    names[i] = [NSString stringWithUTF8String:namebuf];
                    namebuf += strlen(namebuf) + 1;
                }
                [context setValue:names forEventRequest:req];
            }];
}

@end
