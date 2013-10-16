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

    NSLog(@"libuv version: %s", uv_version_string());

    _Stats = [JSValue valueWithNewObjectInContext:[JSContext currentContext]];
    _Stats[@"prototype"] = [JSValue valueWithNewObjectInContext:[JSContext currentContext]];

    return self;

}

- (id)binding {
    return self;
}

static void after(uv_fs_t* req) {
    NSLog(@"after %li", req->result);
    JSValue *cb = CFBridgingRelease(req->data);
    NSNumber *result = [NSNumber numberWithLong:req->result];
    uv_fs_req_cleanup(req);
    [cb callWithArguments:@[result]];
}

- (id)open:(NSString *)path withFlags:(NSNumber *)flags andMode:(NSNumber *)mode andCallback:(JSValue *)cb {
    Boolean async = ![cb isUndefined];
    uv_fs_t *req = malloc(sizeof(uv_fs_t));
    req->data = (void *)CFBridgingRetain(cb);
    NLContext *context = [NLContext currentContext];
    int error = [context runEventTask:uv_fs_open(context.eventLoop, req,
                                                 [path cStringUsingEncoding:NSUTF8StringEncoding],
                                                 [flags intValue], [mode intValue], async ? after : nil)];
    if (async) {
        return nil;
    } else {
        uv_fs_req_cleanup(req);
        return [NSNumber numberWithInt:error];
    }

}

@end
