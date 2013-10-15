//
//  NLBindingFilesystem.m
//  NodelikeDemo
//
//  Created by Sam Rijs on 10/13/13.
//  Copyright (c) 2013 Sam Rijs. All rights reserved.
//

#import "NLBindingFilesystem.h"

#import "uv.h"

@implementation NLBindingFilesystem

- (id)init {

    self = [super init];

    NSLog(@"libuv version: %s", uv_version_string());

    _Stats = [JSValue valueWithNewObjectInContext:[JSContext currentContext]];
    _Stats[@"prototype"] = [JSValue valueWithNewObjectInContext:[JSContext currentContext]];

    return self;

}

- (id)binding {
    return self;
}

@end
