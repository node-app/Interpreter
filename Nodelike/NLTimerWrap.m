//
//  NLTimer.m
//  NodelikeDemo
//
//  Created by Sam Rijs on 10/30/13.
//  Copyright (c) 2013 Sam Rijs. All rights reserved.
//

#import "NLTimerWrap.h"

static const uint32_t kOnTimeout = 0;

@implementation NLTimerWrap {
    uv_timer_t handle;
}

+ (id)binding {
    NLContext *context   = [NLContext currentContext];
    JSValue   *timer     = [NLBinding makeConstructor:^{ return [[NLTimerWrap alloc] init]; } inContext:context];
    timer[@"kOnTimeout"] = [NSNumber numberWithUnsignedInt:kOnTimeout];
    timer[@"now"]        = ^{ return [NSNumber numberWithDouble:uv_now(context.eventLoop)]; };
    return @{@"Timer": timer};
}

- (id)init {
    return [self initInContext:[NLContext currentContext]];
}

- (id)initInContext:(NLContext *)context {
    self = [super initWithHandle:(uv_handle_t *)&self->handle inContext:context];
    int r = uv_timer_init(context.eventLoop, &self->handle);
    assert(r == 0);
    return self;
}

- (NSNumber *)start:(NSNumber *)timeout repeat:(NSNumber *)repeat {
    int err = uv_timer_start(&self->handle, onTimeout, [timeout intValue], [repeat intValue]);
    return [NSNumber numberWithInt:err];
}

- (NSNumber *)stop {
    return [NSNumber numberWithInt:uv_timer_stop(&self->handle)];
}

- (NSNumber *)setRepeat:(NSNumber *)repeat {
    uv_timer_set_repeat(&self->handle, [repeat intValue]);
    return @0;
}

- (NSNumber *)getRepeat {
    return [NSNumber numberWithDouble:uv_timer_get_repeat(&self->handle)];
}

- (NSNumber *)again {
    int err = uv_timer_again(&self->handle);
    return [NSNumber numberWithInt:err];
}

static void onTimeout(uv_timer_t *handle, int status) {
    JSValue     *wrap       = (__bridge JSValue *)(handle->data);
    JSObjectRef  wrapRef    = (JSObjectRef)[wrap JSValueRef];
    JSContextRef contextRef = [[wrap context] JSGlobalContextRef];
    JSValueRef   callback   = JSObjectGetPropertyAtIndex(contextRef, wrapRef, kOnTimeout, nil);
    if (callback && JSValueIsObject(contextRef, callback) && JSObjectIsFunction(contextRef, (JSObjectRef)callback)) {
        JSValueRef arg = JSValueMakeNumber(contextRef, status);
        JSObjectCallAsFunction(contextRef, (JSObjectRef)callback, wrapRef, 1, &arg, nil);
    }
}

@end
