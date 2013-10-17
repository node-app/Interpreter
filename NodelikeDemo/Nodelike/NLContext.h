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

+ (void)finishEventRequest:(void *)req do:(void(^)(NLContext *context, JSValue **errorArg, JSValue **valueArg))task;

- (JSValue *)errorForEventRequestError:(int)error;

- (id)throwNewErrorWithMessage:(NSString *)message;

@end
