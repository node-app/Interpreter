//
//  NLHandle.h
//  NodelikeDemo
//
//  Created by Sam Rijs on 10/28/13.
//  Copyright (c) 2013 Sam Rijs. All rights reserved.
//

#import "NLBinding.h"

@protocol NLHandleExports <JSExport>

+ (void)ref;
+ (void)unref;
+ (void)close:(JSValue *)cb;

@end

static const unsigned int kUnref = 1;
static const unsigned int kCloseCallback = 2;

@interface NLHandle : NLBinding <NLHandleExports>

- (id)initWithHandle:(uv_handle_t *)handle;

@end
