//
//  NLBinding.h
//  NodelikeDemo
//
//  Created by Sam Rijs on 10/13/13.
//  Copyright (c) 2013 Sam Rijs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "uv.h"

#import "NLContext.h"

@interface NLBinding : NSObject

+ (id)bindingForIdentifier:(NSString *)identifier;

- (id)binding;

- (id)throwNewErrorWithMessage:(NSString *)message;

@end
