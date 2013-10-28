//
//  NLBindingUv.m
//  NodelikeDemo
//
//  Created by Sam Rijs on 10/28/13.
//  Copyright (c) 2013 Sam Rijs. All rights reserved.
//

#import "NLBindingUv.h"

#import "uv.h"

@implementation NLBindingUv

+ (id)binding {

    NSMutableDictionary *b = [[NSMutableDictionary alloc] init];

    b[@"errname"] = ^(NSNumber *err) {
        return [NSString stringWithUTF8String:uv_err_name([err intValue])];
    };

#define V(name, _) [b setObject:[NSNumber numberWithInt:UV_ ## name] forKey:@"UV_" # name];
    UV_ERRNO_MAP(V)
#undef V

    return b;

}

@end
