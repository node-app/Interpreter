//
//  NLCaresWrap.h
//  NodelikeDemo
//
//  Created by Sam Rijs on 10/21/13.
//  Copyright (c) 2013 Sam Rijs. All rights reserved.
//

#import "NLBinding.h"

@protocol NLCaresWrapExports <JSExport>

+ (NSNumber *)isIP:(NSString *)ip;

@end

@interface NLCaresWrap : NLBinding <NLCaresWrapExports>

@end
