//
//  NLBindingFilesystem.h
//  NodelikeDemo
//
//  Created by Sam Rijs on 10/13/13.
//  Copyright (c) 2013 Sam Rijs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol NLBindingFilesystemExports <JSExport>

@property JSValue *Stats;

@end

@interface NLBindingFilesystem : NSObject <NLBindingFilesystemExports>

@property JSValue *Stats;

@end
