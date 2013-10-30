//
//  NLHandle.m
//  NodelikeDemo
//
//  Created by Sam Rijs on 10/28/13.
//  Copyright (c) 2013 Sam Rijs. All rights reserved.
//

#import "NLHandle.h"

@implementation NLHandle {

    unsigned int flags;
    
}

+ (NSMutableArray *)handleQueue {
    static NSMutableArray *queue;
    static dispatch_once_t token = 0;
    dispatch_once(&token, ^{
        queue = [[NSMutableArray alloc] init];
    });
    return queue;
}

- (void)ref {
    NLHandle *handle = self;
    if (handle != nil && handle.handle != nil) {
        uv_ref(handle.handle);
        handle->flags &= ~kUnref;
    }
}

- (void)unref {
    NLHandle *handle = self;
    if (handle != nil && handle.handle != nil) {
        uv_unref(handle.handle);
        handle->flags |= kUnref;
    }
}

- (void)close:(JSValue *)cb {
    NLHandle *handle = self;
    if (handle == nil || handle.handle == nil) {
        return;
    }
    uv_close(handle.handle, onClose);
    handle.handle = nil;
    if (![cb isUndefined]) {
        handle.closeCallback = cb;
        handle->flags |= kCloseCallback;
    }
}

- (id)initWithHandle:(uv_handle_t *)handle inContext:(NLContext *)context {
    self = [super init];
    self->flags = 0;
    self.handle = handle;
    self.handle->data = (void *)CFBridgingRetain([JSValue valueWithObject:self inContext:context]);
    self.weakValue = [NSValue valueWithNonretainedObject:self];
    [[NLHandle handleQueue] addObject:self.weakValue];
    return self;
}

- (void)dealloc {
    [[NLHandle handleQueue] removeObject:self.weakValue];
}

void onClose(uv_handle_t *handle) {
    NLHandle *wrap = [(JSValue *)CFBridgingRelease(handle->data) toObjectOfClass:[NLHandle class]];
    if (wrap->flags & kCloseCallback) {
        [wrap.closeCallback callWithArguments:@[]];
    }
}

@end
