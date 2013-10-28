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

+ (id)binding {
    return [[self alloc] init];
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

#define REQ(r)  ((uv_fs_t *)r)
#define INT(x)  [x intValue]
#define UINT(x) [x unsignedIntValue]
#define STR(x)  [x UTF8String]

#define CALL(fun, cb, ...)                                          \
    NLContext createEventRequestOfType:UV_FS withCallback:cb do:    \
     ^(uv_loop_t *loop, void *req, bool async) {                    \
        uv_fs_ ## fun(loop, req, __VA_ARGS__, async ? after : nil); \
        if (!async) after(req);                                     \
    } then:

- (JSValue *)open:(longlived NSString *)path flags:(NSNumber *)flags mode:(NSNumber *)mode callback:(JSValue *)cb {
    return [CALL(open, cb, STR(path), INT(flags), INT(mode))
            ^(void *req, NLContext *context) {
                [context setValue:[JSValue valueWithInt32:REQ(req)->result inContext:context] forEventRequest:req];
            }];
}

- (JSValue *)close:(NSNumber *)file callback:(JSValue *)cb {
    return [CALL(close, cb, INT(file)) nil];
}

- (JSValue *)read:(NSNumber *)file to:(JSValue *)target offset:(JSValue *)off length:(JSValue *)len pos:(JSValue *)pos callback:(JSValue *)cb {
    unsigned int buffer_length = [target[@"length"] toUInt32];
    unsigned int length   = [off isUndefined] ? buffer_length : [off toUInt32];
    unsigned int position = [pos isUndefined] ?             0 : [pos toUInt32];
    return [CALL(read, cb, [file intValue], malloc(length), length, position)
            ^(void *req, NLContext *context) {
                [NLBindingBuffer write:REQ(req)->buf toBuffer:target atOffset:off withLength:len];
                [context setValue:[JSValue valueWithInt32:REQ(req)->result inContext:context] forEventRequest:req];
            }];

}

- (JSValue *)readDir:(longlived NSString *)path callback:(JSValue *)cb {
    return [CALL(readdir, cb, [path UTF8String], 0)
            ^(void *req, NLContext *context) {
                char *namebuf = REQ(req)->ptr;
                int i, nnames = REQ(req)->result;
                JSValue *names = [JSValue valueWithNewArrayInContext:context];
                for (i = 0; i < nnames; i++) {
                    names[i] = [NSString stringWithUTF8String:namebuf];
                    namebuf += strlen(namebuf) + 1;
                }
                [context setValue:names forEventRequest:req];
            }];
}

- (JSValue *)fdatasync:(NSNumber *)file callback:(JSValue *)cb {
    return [CALL(fdatasync, cb, INT(file)) nil];
}

- (JSValue *)fsync:(NSNumber *)file callback:(JSValue *)cb {
    return [CALL(fsync, cb, INT(file)) nil];
}

- (JSValue *)rename:(longlived NSString *)oldpath to:(longlived NSString *)newpath callback:(JSValue *)cb {
    return [CALL(rename, cb, STR(oldpath), STR(newpath)) nil];
}

- (JSValue *)ftruncate:(NSNumber *)file length:(NSNumber *)len callback:(JSValue *)cb {
    return [CALL(ftruncate, cb, INT(file), INT(file)) nil];
}

- (JSValue *)rmdir:(longlived NSString *)path callback:(JSValue *)cb {
    return [CALL(rmdir, cb, STR(path)) nil];
}

- (JSValue *)mkdir:(longlived NSString *)path mode:(NSNumber *)mode callback:(JSValue *)cb {
    return [CALL(mkdir, cb, STR(path), INT(mode)) nil];
}

- (JSValue *)link:(longlived NSString *)dst from:(longlived NSString *)src callback:(JSValue *)cb {
    return [CALL(link, cb, STR(dst), STR(src)) nil];
}

- (JSValue *)symlink:(longlived NSString *)dst from:(longlived NSString *)src mode:(NSString *)mode callback:(JSValue *)cb {
    // we ignore the mode argument because it is only effective on windows platforms
    return [CALL(symlink, cb, STR(dst), STR(src), 0 /*flags*/) nil];
}

- (JSValue *)readlink:(longlived NSString *)path callback:(JSValue *)cb {
    return [CALL(readlink, cb, STR(path)) ^(void *req, NLContext *context) {
        NSString *str = [NSString stringWithUTF8String:REQ(req)->ptr];
        [context setValue:[JSValue valueWithObject:str inContext:context] forEventRequest:req];
    }];
}

- (JSValue *)unlink:(longlived NSString *)path callback:(JSValue *)cb {
    return [CALL(unlink, cb, STR(path)) nil];
}

- (JSValue *)chmod:(longlived NSString *)path mode:(NSNumber *)mode callback:(JSValue *)cb {
    return [CALL(chmod, cb, STR(path), INT(mode)) nil];
}

- (JSValue *)fchmod:(NSNumber *)file mode:(NSNumber *)mode callback:(JSValue *)cb {
    return [CALL(fchmod, cb, INT(file), INT(mode)) nil];
}

- (JSValue *)chown:(longlived NSString *)path uid:(NSNumber *)uid gid:(NSNumber *)gid callback:(JSValue *)cb {
    return [CALL(chown, cb, STR(path), UINT(uid), UINT(gid)) nil];
}

- (JSValue *)fchown:(NSNumber *)file uid:(NSNumber *)uid gid:(NSNumber *)gid callback:(JSValue *)cb {
    return [CALL(fchown, cb, INT(file), UINT(uid), UINT(gid)) nil];
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
    return [CALL(stat, cb, STR(path)) ^(void *req, NLContext *context) {
        [context setValue:[self buildStatsObject:REQ(req)->ptr inContext:context] forEventRequest:req];
    }];
}

- (JSValue *)lstat:(longlived NSString *)path callback:(JSValue *)cb {
    return [CALL(lstat, cb, STR(path)) ^(void *req, NLContext *context) {
        [context setValue:[self buildStatsObject:REQ(req)->ptr inContext:context] forEventRequest:req];
    }];
}

- (JSValue *)fstat:(longlived NSNumber *)file callback:(JSValue *)cb {
    return [CALL(fstat, cb, INT(file)) ^(void *req, NLContext *context) {
        [context setValue:[self buildStatsObject:REQ(req)->ptr inContext:context] forEventRequest:req];
    }];
}

@end
