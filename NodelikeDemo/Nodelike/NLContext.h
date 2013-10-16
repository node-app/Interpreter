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

- (JSValue *)runEventRequest:(void(^)(uv_loop_t *loop, void *req, bool async))task
                      ofType:(uv_req_type)type withCallback:(JSValue *)cb;

- (void)finishEventRequestWithData:(void *)data error:(JSValue *)errorArg value:(JSValue *)valueArg;

- (id)throwNewErrorWithMessage:(NSString *)message;

@end
