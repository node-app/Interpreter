//
//  NLBindingSmalloc.m
//  NodelikeDemo
//
//  Created by Sam Rijs on 10/19/13.
//  Copyright (c) 2013 Sam Rijs. All rights reserved.
//

#import "NLBindingSmalloc.h"

@implementation NLBindingSmalloc

- (JSValue *)smallocAlloc:(JSValue *)target size:(NSNumber *)size {
    return [JSValue valueWithNullInContext:[NLContext currentContext]];
}

- (id)binding {
    return @{@"alloc": ^(JSValue *target, NSNumber *size) { [self smallocAlloc:target size:size];}};
}

@end
