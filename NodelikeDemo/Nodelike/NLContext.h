//
//  NLContext.h
//  NodelikeDemo
//
//  Created by Sam Rijs on 10/13/13.
//  Copyright (c) 2013 Sam Rijs. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>

#import "uv.h"

@interface NLContext : JSContext

+ (NLContext *)currentContext;

+ (NLContext *)contextForEventRequest:(void *)req;

+ (JSValue *)createEventRequestOfType:(uv_req_type)type withCallback:(JSValue *)cb
                                   do:(void(^)(uv_loop_t *loop, void *req, bool async))task;

+ (void)finishEventRequest:(void *)req do:(void(^)(NLContext *context))task;

- (void)setErrorCode:(int)error forEventRequest:(void *)req;

- (void)setError:(JSValue *)error forEventRequest:(void *)req;

- (void)setValue:(JSValue *)value forEventRequest:(void *)req;

@end
