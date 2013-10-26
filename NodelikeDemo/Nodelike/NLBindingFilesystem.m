//
//  NLBindingFilesystem.m
//  NodelikeDemo
//
//  Created by Sam Rijs on 10/13/13.
//  Copyright (c) 2013 Sam Rijs. All rights reserved.
//

#import "NLBindingFilesystem.h"

#import "NLBindingBuffer.h"

@implementation NLBindingFilesystem

- (id)init {

    self = [super init];

    _Stats = [JSValue valueWithNewObjectInContext:[JSContext currentContext]];
    _Stats[@"prototype"] = [JSValue valueWithNewObjectInContext:[JSContext currentContext]];

    return self;

}

static void after(uv_fs_t* req) {
    [NLContext finishEventRequest:req do:
     ^(NLContext *context) {
         if (req->result < 0) {
             [context setErrorCode:req->result forEventRequest:req];
         } else {
             [context callSuccessfulEventRequest:req];
         }
         uv_fs_req_cleanup(req);
     }];
}

#define CALL(fun, cb, ...)                                          \
    NLContext createEventRequestOfType:UV_FS withCallback:cb do:    \
     ^(uv_loop_t *loop, void *req, bool async) {                    \
        uv_fs_ ## fun(loop, req, __VA_ARGS__, async ? after : nil); \
        if (!async) after(req);                                     \
    } then:

- (JSValue *)open:(longlived NSString *)path flags:(NSNumber *)flags mode:(NSNumber *)mode callback:(JSValue *)cb {
    return [CALL(open, cb, [path UTF8String], [flags intValue], [mode intValue])
            ^(void *req_, NLContext *context) {
                uv_fs_t *req = req_;
                [context setValue:[JSValue valueWithInt32:req->result inContext:context] forEventRequest:req];
            }];
}

- (JSValue *)close:(NSNumber *)file callback:(JSValue *)cb {
    return [CALL(close, cb, [file intValue]) nil];
}

- (JSValue *)read:(NSNumber *)file to:(JSValue *)target offset:(JSValue *)off length:(JSValue *)len pos:(JSValue *)pos callback:(JSValue *)cb {
    unsigned int buffer_length = [target[@"length"] toUInt32];
    unsigned int length   = [off isUndefined] ? buffer_length : [off toUInt32];
    unsigned int position = [pos isUndefined] ?             0 : [pos toUInt32];
    return [CALL(read, cb, [file intValue], malloc(length), length, position)
            ^(void *req_, NLContext *context) {
                uv_fs_t *req = req_;
                NSData *data = [NSData dataWithBytesNoCopy:req->buf length:length freeWhenDone:YES];
                [NLBindingBuffer writeData:data toBuffer:target atOffset:off withLength:len];
                [context setValue:[JSValue valueWithInt32:req->result inContext:context] forEventRequest:req];
            }];

}

- (JSValue *)readDir:(longlived NSString *)path callback:(JSValue *)cb {
    return [CALL(readdir, cb, [path UTF8String], 0)
            ^(void *req_, NLContext *context) {
                uv_fs_t *req = req_;
                char *namebuf = req->ptr;
                int i, nnames = req->result;
                JSValue *names = [JSValue valueWithNewArrayInContext:context];
                for (i = 0; i < nnames; i++) {
                    names[i] = [NSString stringWithUTF8String:namebuf];
                    namebuf += strlen(namebuf) + 1;
                }
                [context setValue:names forEventRequest:req];
            }];
}

- (JSValue *)fdatasync:(NSNumber *)file callback:(JSValue *)cb {
    return [CALL(fdatasync, cb, [file intValue]) nil];
}

- (JSValue *)fsync:(NSNumber *)file callback:(JSValue *)cb {
    return [CALL(fsync, cb, [file intValue]) nil];
}

- (JSValue *)rename:(longlived NSString *)oldpath to:(longlived NSString *)newpath callback:(JSValue *)cb {
    return [CALL(rename, cb, [oldpath UTF8String], [newpath UTF8String]) nil];
}

- (JSValue *)ftruncate:(NSNumber *)file length:(NSNumber *)len callback:(JSValue *)cb {
    return [CALL(ftruncate, cb, [file intValue], [len intValue]) nil];
}

- (JSValue *)rmdir:(longlived NSString *)path callback:(JSValue *)cb {
    return [CALL(rmdir, cb, [path UTF8String]) nil];
}

- (JSValue *)mkdir:(longlived NSString *)path mode:(NSNumber *)mode callback:(JSValue *)cb {
    return [CALL(mkdir, cb, [path UTF8String], [mode intValue]) nil];
}

- (JSValue *)link:(longlived NSString *)dst from:(longlived NSString *)src callback:(JSValue *)cb {
    return [CALL(link, cb, [dst UTF8String], [src UTF8String]) nil];
}

- (JSValue *)symlink:(longlived NSString *)dst from:(longlived NSString *)src mode:(NSString *)mode callback:(JSValue *)cb {
    // we ignore the mode argument because it is only effective on windows platforms
    return [CALL(symlink, cb, [dst UTF8String], [src UTF8String], 0 /*flags*/) nil];
}

- (JSValue *)readlink:(longlived NSString *)path callback:(JSValue *)cb {
    return [CALL(readlink, cb, [path UTF8String]) ^(void *req_, NLContext *context) {
        uv_fs_t *req = req_;
        NSString *str = [NSString stringWithUTF8String:req->ptr];
        [context setValue:[JSValue valueWithObject:str inContext:context] forEventRequest:req];
    }];
}

- (JSValue *)unlink:(longlived NSString *)path callback:(JSValue *)cb {
    return [CALL(unlink, cb, [path UTF8String]) nil];
}

- (JSValue *)chmod:(longlived NSString *)path mode:(NSNumber *)mode callback:(JSValue *)cb {
    return [CALL(chmod, cb, [path UTF8String], [mode intValue]) nil];
}

- (JSValue *)fchmod:(NSNumber *)file mode:(NSNumber *)mode callback:(JSValue *)cb {
    return [CALL(fchmod, cb, [file intValue], [mode intValue]) nil];
}

- (JSValue *)chown:(longlived NSString *)path uid:(NSNumber *)uid_ gid:(NSNumber *)gid_ callback:(JSValue *)cb {
    uv_uid_t uid = [uid_ unsignedIntValue];
    uv_gid_t gid = [gid_ unsignedIntValue];
    return [CALL(chown, cb, [path UTF8String], uid, gid) nil];
}

- (JSValue *)fchown:(NSNumber *)file uid:(NSNumber *)uid_ gid:(NSNumber *)gid_ callback:(JSValue *)cb {
    uv_uid_t uid = [uid_ unsignedIntValue];
    uv_gid_t gid = [gid_ unsignedIntValue];
    return [CALL(fchown, cb, [file intValue], uid, gid) nil];
}

#pragma mark stat

- (JSValue *)buildStatsObject:(const uv_stat_t *)s inContext:(JSContext *)context {
    JSValue *stats = [JSValue valueWithNewObjectInContext:context];
    stats[@"__proto__"] = _Stats[@"prototype"];
    stats[@"dev"]     = [JSValue valueWithInt32:s->st_dev    inContext:context];
    stats[@"mode"]    = [JSValue valueWithInt32:s->st_mode   inContext:context];
    stats[@"nlink"]   = [JSValue valueWithInt32:s->st_nlink  inContext:context];
    stats[@"uid"]     = [JSValue valueWithInt32:s->st_uid    inContext:context];
    stats[@"gid"]     = [JSValue valueWithInt32:s->st_gid    inContext:context];
    stats[@"rdev"]    = [JSValue valueWithInt32:s->st_rdev   inContext:context];
    stats[@"ino"]     = [JSValue valueWithInt32:s->st_ino    inContext:context];
    stats[@"size"]    = [JSValue valueWithInt32:s->st_size   inContext:context];
    stats[@"blocks"]  = [JSValue valueWithInt32:s->st_blocks inContext:context];
    // @TODO: atime, mtime, ctime, birthtime
    return stats;
}

- (JSValue *)stat:(longlived NSString *)path callback:(JSValue *)cb {
    return [CALL(stat, cb, [path UTF8String]) ^(void *req_, NLContext *context) {
        uv_fs_t *req = req_;
        [context setValue:[self buildStatsObject:req->ptr inContext:context] forEventRequest:req];
    }];
}

- (JSValue *)lstat:(longlived NSString *)path callback:(JSValue *)cb {
    return [CALL(lstat, cb, [path UTF8String]) ^(void *req_, NLContext *context) {
        uv_fs_t *req = req_;
        [context setValue:[self buildStatsObject:req->ptr inContext:context] forEventRequest:req];
    }];
}

- (JSValue *)fstat:(longlived NSNumber *)file callback:(JSValue *)cb {
    return [CALL(fstat, cb, [file intValue]) ^(void *req_, NLContext *context) {
        uv_fs_t *req = req_;
        [context setValue:[self buildStatsObject:req->ptr inContext:context] forEventRequest:req];
    }];
}

@end
