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

+ (NSNumber *)writeString:(longlived NSString *)str toBuffer:(JSValue *)target atOffset:(JSValue *)off withLength:(JSValue *)len {

    return [NLBindingBuffer write:[str UTF8String] toBuffer:target atOffset:off withLength:len];

}

+ (NSNumber *)write:(const char *)data toBuffer:(JSValue *)target atOffset:(JSValue *)off withLength:(JSValue *)len {
    
    size_t obj_length = [target[@"length"] toUInt32];
    
    size_t offset;
    size_t max_length;
    
    offset     = [off isUndefined] ?                   0 : [off toUInt32];
    max_length = [len isUndefined] ? obj_length - offset : [len toUInt32];
    
    max_length = MIN(obj_length - offset, max_length);
    
    for (int i = 0; i < max_length; i++) {
        JSValue *val = [JSValue valueWithInt32:data[i] inContext:target.context];
        [target setObject:val atIndexedSubscript:i + offset];
    }
    
    return [NSNumber numberWithUnsignedInteger:max_length];
    
}

- (void)setupBufferJS:(JSValue *)target internal:(JSValue *)internal {

    JSValue *proto = target[@"prototype"];
    
    proto[@"asciiWrite"] = ^(NSString *string, JSValue *off, JSValue *len) {
        return [NLBindingBuffer writeString:string toBuffer:[NLContext currentThis] atOffset:off withLength:len];
    };
    
    proto[@"binaryWrite"] = ^(NSString *string, JSValue *off, JSValue *len) {
        return [NLBindingBuffer writeString:string toBuffer:[NLContext currentThis] atOffset:off withLength:len];
    };
    
    proto[@"utf8Write"] = ^(NSString *string, JSValue *off, JSValue *len) {
        return [NLBindingBuffer writeString:string toBuffer:[NLContext currentThis] atOffset:off withLength:len];
    };
    
    internal[@"byteLength"] = ^(NSString *string) {
        return [string lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    };
    
}

@end
