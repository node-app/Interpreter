//
//  NLHandle.h
//  NodelikeDemo
//
//  Created by Sam Rijs on 10/28/13.
//  Copyright (c) 2013 Sam Rijs. All rights reserved.
//

#import "NLBinding.h"

@protocol NLHandleExports <JSExport>

- (void)ref;
- (void)unref;
- (void)close:(JSValue *)cb;

@end

@interface NLHandle : NLBinding <NLHandleExports>

@property (readonly) uv_handle_t *handle;
@property (readonly) JSValue     *closeCallback;
@property (readonly) NSValue     *weakValue;

- (id)initWithHandle:(uv_handle_t *)handle inContext:(NLContext *)context;

@end
