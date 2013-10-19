//
//  NLBindingBuffer.m
//  NodelikeDemo
//
//  Created by Sam Rijs on 10/19/13.
//  Copyright (c) 2013 Sam Rijs. All rights reserved.
//

#import "NLBindingBuffer.h"

@implementation NLBindingBuffer

- (id)binding {
    return @{@"setupBufferJS": ^(JSValue *target, JSValue *internal) {
        [self setupBufferJS:target internal:internal];}};
}
    
- (void)setupBufferJS:(JSValue *)target internal:(JSValue *)internal {
}

@end
