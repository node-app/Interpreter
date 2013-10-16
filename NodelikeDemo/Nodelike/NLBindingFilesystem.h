//
//  NLBindingFilesystem.h
//  NodelikeDemo
//
//  Created by Sam Rijs on 10/13/13.
//  Copyright (c) 2013 Sam Rijs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

#import "NLBinding.h"

@protocol NLBindingFilesystemExports <JSExport>

@property JSValue *Stats;

JSExportAs(open, - (id)open:(NSString *)path withFlags:(NSNumber *)flags andMode:(NSNumber *)mode andCallback:(JSValue *)cb);

@end

@interface NLBindingFilesystem : NLBinding <NLBindingFilesystemExports>

@property JSValue *Stats;

@end
