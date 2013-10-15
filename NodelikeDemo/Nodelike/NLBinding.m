//
//  NLBinding.m
//  NodelikeDemo
//
//  Created by Sam Rijs on 10/13/13.
//  Copyright (c) 2013 Sam Rijs. All rights reserved.
//

#import "NLBinding.h"

#import "NLBindingFilesystem.h"
#import "NLBindingConstants.h"

@implementation NLBinding

- (id)binding {
    return nil;
}

+ (id)bindingForIdentifier:(NSString *)identifier {
    static NSDictionary *bindings;
    if (bindings == nil) {
        bindings = @{@"fs":        [NLBindingFilesystem class],
                     @"constants": [NLBindingConstants  class]};
    }
    Class cls = bindings[identifier];
    if (cls) {
        return [[[cls alloc] init] binding];
    } else {
        return nil;
    }
}

- (id)throwNewErrorWithMessage:(NSString *)message {
    JSContext *context = [JSContext currentContext];
    context.exception = [JSValue valueWithNewErrorFromMessage:message inContext:context];
    return nil;
}

@end
