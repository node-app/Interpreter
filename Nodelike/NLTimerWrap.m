//
//  NLTimer.m
//  NodelikeDemo
//
//  Created by Sam Rijs on 10/30/13.
//  Copyright (c) 2013 Sam Rijs. All rights reserved.
//

#import "NLTimerWrap.h"

static const unsigned int kOnTimeout = 0;

@implementation NLTimerWrap {
    uv_timer_t handle;
}

+ (id)binding {
    JSValue   *timer     = [NLBinding makeConstructor:^{ return [[NLTimerWrap alloc] init]; } inContext:[NLContext currentContext]];
    timer[@"kOnTimeout"] = [NSNumber numberWithUnsignedInt:kOnTimeout];
    timer[@"now"]        = ^{
        uv_loop_t *eventLoop = [[NLContext currentContext] eventLoop];
        uv_update_time(eventLoop);
        return [NSNumber numberWithDouble:uv_now(eventLoop)];
    };
    return @{@"Timer": timer};
}

- (id)init {
    return [self initInContext:[NLContext currentContext]];
}

- (id)initInContext:(NLContext *)context {
    self = [super initWithHandle:(uv_handle_t *)&handle inContext:context];
    int r = uv_timer_init(context.eventLoop, &handle);
    assert(r == 0);
    return self;
}

- (NSNumber *)start:(NSNumber *)timeout repeat:(NSNumber *)repeat {
    return [NSNumber numberWithInt:uv_timer_start(&handle, onTimeout, [timeout intValue], [repeat intValue])];
}

- (NSNumber *)stop {
    return [NSNumber numberWithInt:uv_timer_stop(&handle)];
}

- (NSNumber *)setRepeat:(NSNumber *)repeat {
    uv_timer_set_repeat(&handle, [repeat intValue]);
    return @0;
}

- (NSNumber *)getRepeat {
    return [NSNumber numberWithDouble:uv_timer_get_repeat(&handle)];
}

- (NSNumber *)again {
    return [NSNumber numberWithInt:uv_timer_again(&handle)];
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
