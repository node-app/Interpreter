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

+ (NSDictionary *)bindings {
    static NSDictionary *bindings = nil;
    static dispatch_once_t token = 0;
    dispatch_once(&token, ^{
        bindings = @{@"fs":        [NLBindingFilesystem class],
                     @"constants": [NLBindingConstants  class]};
    });
    return bindings;
}

+ (id)bindingForIdentifier:(NSString *)identifier {
    Class cls = [NLBinding bindings][identifier];
    if (cls) {
        return [[[cls alloc] init] binding];
    } else {
        return nil;
    }
}

- (id)binding {
    return self;
}

@end
