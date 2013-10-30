//
//  NLBinding.h
//  NodelikeDemo
//
//  Created by Sam Rijs on 10/13/13.
//  Copyright (c) 2013 Sam Rijs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

#import "uv.h"

#import "NLContext.h"

// In order to guarantee that the C string derived from an
// NSString -UTF8String method call survives until libuv
// gets a chance to copy it, it is annotated with the following
// attribute, which guarantees that the object will be alive until
// the end of the scope.
#define longlived __attribute((objc_precise_lifetime))

@interface NLBinding : NSObject

+ (id)bindingForIdentifier:(NSString *)identifier;

+ (id)binding;

+ (JSValue *)makeConstructor:(id)block inContext:(JSContext *)context;

@end
