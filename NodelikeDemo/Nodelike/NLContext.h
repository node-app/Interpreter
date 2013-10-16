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

@property (readonly) uv_loop_t *eventLoop;

+ (NLContext *)currentContext;

- (int)runEventTask:(int)result;

- (id)throwNewErrorWithMessage:(NSString *)message;

@end
