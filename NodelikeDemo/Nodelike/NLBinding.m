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

+ (id) bindingForIdentifier:(NSString *)identifier {
    static NSDictionary *bindings;
    if (bindings == nil) {
        bindings = @{@"fs":        [NLBindingFilesystem class],
                     @"constants": [NLBindingConstants  class]};
    }
    Class cls = bindings[identifier];
    if (cls) {
        return [[cls alloc] init];
    } else {
        return nil;
    }
}

@end
