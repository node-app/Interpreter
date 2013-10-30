//
//  NLTimer.h
//  NodelikeDemo
//
//  Created by Sam Rijs on 10/30/13.
//  Copyright (c) 2013 Sam Rijs. All rights reserved.
//

#import "NLHandle.h"

@protocol NLTimerWrapExports <JSExport>

- (void)ref;
- (void)unref;
- (void)close:(JSValue *)cb;

JSExportAs(start, - (NSNumber *)start:(NSNumber *)timeout repeat:(NSNumber *)repeat);
- (NSNumber *)stop;
- (NSNumber *)setRepeat:(NSNumber *)repeat;
- (NSNumber *)getRepeat;
- (NSNumber *)again;

@end

@interface NLTimerWrap : NLHandle <NLTimerWrapExports>

@end
