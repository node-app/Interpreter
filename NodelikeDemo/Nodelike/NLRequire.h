//
//  NLRequire.h
//  NodelikeDemo
//
//  Created by Sam Rijs on 10/13/13.
//  Copyright (c) 2013 Sam Rijs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@interface NLRequire : NSObject

+ (JSValue *)require:(NSString *)module inContext:(JSContext *)context;

@end
