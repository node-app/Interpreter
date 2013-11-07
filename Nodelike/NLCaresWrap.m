//
//  NLCaresWrap.m
//  NodelikeDemo
//
//  Created by Sam Rijs on 10/21/13.
//  Copyright (c) 2013 Sam Rijs. All rights reserved.
//

#import "NLCaresWrap.h"

@implementation NLCaresWrap

+ (NSNumber *)isIP:(NSString *)ip {
    char address_buffer[sizeof(struct in6_addr)];
    int rc = 0;
    if (uv_inet_pton(AF_INET, [ip UTF8String], &address_buffer) == 0)
        rc = 4;
    else if (uv_inet_pton(AF_INET6, [ip UTF8String], &address_buffer) == 0)
        rc = 6;
    return [NSNumber numberWithInt:rc];
}

@end
