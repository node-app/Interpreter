//
//  NLContext.h
//  NodelikeDemo
//
//  Created by Sam Rijs on 10/13/13.
//  Copyright (c) 2013 Sam Rijs. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>

@interface NLContext : JSContext

+ (void)attachToContext:(JSContext *)context;

+ (JSValue *)requireModule:(NSString *)module inContext:(JSContext *)context;

- (JSValue *)requireModule:(NSString *)module;

+ (void)runEventLoop;

@end
