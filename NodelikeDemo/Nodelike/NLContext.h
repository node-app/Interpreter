//
//  NLContext.h
//  NodelikeDemo
//
//  Created by Sam Rijs on 10/13/13.
//  Copyright (c) 2013 Sam Rijs. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>

#import "uv.h"

struct data {
    void *callback, *error, *value;
};

@interface NLContext : JSContext

+ (NLContext *)currentContext;

- (id)runEventTask:(void(^)(uv_loop_t *loop, void *req, bool async))task
       withRequest:(void *)req andCallback:(JSValue *)cb;

- (id)throwNewErrorWithMessage:(NSString *)message;

@end
