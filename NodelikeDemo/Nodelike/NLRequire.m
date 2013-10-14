//
//  NLRequire.m
//  NodelikeDemo
//
//  Created by Sam Rijs on 10/13/13.
//  Copyright (c) 2013 Sam Rijs. All rights reserved.
//

#import "NLRequire.h"

#import "NLContext.h"

@implementation NLRequire

+ (JSContext *)createContextForModule:(NSString *)module inContext:(JSContext *)context {

    JSContext *moduleContext = [[NLContext alloc] initWithVirtualMachine:context.virtualMachine];
    
    moduleContext.exceptionHandler = ^(JSContext *context, JSValue *error) {
        NSLog(@"%@: %@", module, error);
    };
    
    JSValue *moduleExports = [JSValue valueWithNewObjectInContext:moduleContext];
    JSValue *moduleModule  = [JSValue valueWithObject:[NSDictionary dictionaryWithObject:moduleExports forKey:@"exports"] inContext:moduleContext];
    
    moduleContext[@"exports"] = moduleExports;
    moduleContext[@"module"]  = moduleModule;
    
    return moduleContext;

}

+ (JSValue *)require:(NSString *)module inContext:(NLContext *)context {
    
    static NSMutableDictionary *requireCache;
    
    if (requireCache == nil) {
        requireCache = [[NSMutableDictionary alloc] init];
    }
    
    id cached = [requireCache objectForKey:module];

    if (cached != nil && [cached isKindOfClass:[JSValue class]]) {
        return cached;
    }
    
    JSContext *moduleContext;
    
    if (cached != nil && [cached isKindOfClass:[JSContext class]]) {
        moduleContext = cached;
    } else {
        moduleContext = [NLRequire createContextForModule:module inContext:context];
        requireCache[module] = moduleContext;
    }
    
    NSString* path = [[NSBundle mainBundle] pathForResource:module
                                                     ofType:@"js"];
    
    NSString* content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    
    if (content != nil) {
        [moduleContext evaluateScript:content];
        JSValue *moduleValue = moduleContext[@"module"][@"exports"];
        requireCache[module] = moduleValue;
        return moduleValue;
    } else {
        NSString *error = [NSString stringWithFormat:@"Cannot find module '%@'", module];
        return [context throwNewErrorWithMessage:error];
    }

}

@end
