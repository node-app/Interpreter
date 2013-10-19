//
//  NLBindingSmalloc.m
//  NodelikeDemo
//
//  Created by Sam Rijs on 10/19/13.
//  Copyright (c) 2013 Sam Rijs. All rights reserved.
//

#import "NLBindingSmalloc.h"

@implementation NLBindingSmalloc

- (id)binding {
    return @{@"alloc":     ^(JSValue *target, NSNumber *size) { return target; },
             @"sliceOnto": ^(JSValue *s, JSValue *d, NSNumber *a, NSNumber *b) { return s; },
             @"kMaxLength": [NSNumber numberWithInt:INT_MAX]};
}

@end
