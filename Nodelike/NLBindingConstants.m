//
//  NLBindingConstants.m
//  NodelikeDemo
//
//  Created by Sam Rijs on 10/13/13.
//  Copyright (c) 2013 Sam Rijs. All rights reserved.
//

#import "NLBindingConstants.h"

#include <errno.h>
#include <unistd.h>
#include <fcntl.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/stat.h>

@implementation NLBindingConstants

+ (id)binding {
    JSContext   *context      = [NLContext currentContext];
    JSContextRef contextRef   = [context JSGlobalContextRef];
    JSObjectRef  constantsRef = JSObjectMake(contextRef, nil, nil);
    define_errnum_constants(constantsRef, contextRef);
    define_signal_constants(constantsRef, contextRef);
    define_system_constants(constantsRef, contextRef);
    return [JSValue valueWithJSValueRef:constantsRef inContext:context];
}

static void define_constant(JSObjectRef target, JSContextRef context, const char *str, double constant) {
    JSStringRef key = JSStringCreateWithUTF8CString(str);
    JSObjectSetProperty(context, target, key, JSValueMakeNumber(context, constant), kJSPropertyAttributeReadOnly, nil);
    JSStringRelease(key);
}

#define CONSTANT(target, contextRef, constant) define_constant(target, contextRef, #constant, constant)

static void define_errnum_constants(JSObjectRef target, JSContextRef contextRef) {
    CONSTANT(target, contextRef, E2BIG);
    CONSTANT(target, contextRef, EACCES);
    CONSTANT(target, contextRef, EADDRINUSE);
    CONSTANT(target, contextRef, EADDRNOTAVAIL);
    CONSTANT(target, contextRef, EAFNOSUPPORT);
    CONSTANT(target, contextRef, EAGAIN);
    CONSTANT(target, contextRef, EALREADY);
    CONSTANT(target, contextRef, EBADF);
    CONSTANT(target, contextRef, EBADMSG);
    CONSTANT(target, contextRef, EBUSY);
    CONSTANT(target, contextRef, ECANCELED);
    CONSTANT(target, contextRef, ECHILD);
    CONSTANT(target, contextRef, ECONNABORTED);
    CONSTANT(target, contextRef, ECONNREFUSED);
    CONSTANT(target, contextRef, ECONNRESET);
    CONSTANT(target, contextRef, EDEADLK);
    CONSTANT(target, contextRef, EDESTADDRREQ);
    CONSTANT(target, contextRef, EDOM);
    CONSTANT(target, contextRef, EDQUOT);
    CONSTANT(target, contextRef, EEXIST);
    CONSTANT(target, contextRef, EFAULT);
    CONSTANT(target, contextRef, EFBIG);
    CONSTANT(target, contextRef, EHOSTUNREACH);
    CONSTANT(target, contextRef, EIDRM);
    CONSTANT(target, contextRef, EILSEQ);
    CONSTANT(target, contextRef, EINPROGRESS);
    CONSTANT(target, contextRef, EINTR);
    CONSTANT(target, contextRef, EINVAL);
    CONSTANT(target, contextRef, EIO);
    CONSTANT(target, contextRef, EISCONN);
    CONSTANT(target, contextRef, EISDIR);
    CONSTANT(target, contextRef, ELOOP);
    CONSTANT(target, contextRef, EMFILE);
    CONSTANT(target, contextRef, EMLINK);
    CONSTANT(target, contextRef, EMSGSIZE);
    CONSTANT(target, contextRef, EMULTIHOP);
    CONSTANT(target, contextRef, ENAMETOOLONG);
    CONSTANT(target, contextRef, ENETDOWN);
    CONSTANT(target, contextRef, ENETRESET);
    CONSTANT(target, contextRef, ENETUNREACH);
    CONSTANT(target, contextRef, ENFILE);
    CONSTANT(target, contextRef, ENOBUFS);
    CONSTANT(target, contextRef, ENODATA);
    CONSTANT(target, contextRef, ENODEV);
    CONSTANT(target, contextRef, ENOENT);
    CONSTANT(target, contextRef, ENOEXEC);
    CONSTANT(target, contextRef, ENOLCK);
    CONSTANT(target, contextRef, ENOLINK);
    CONSTANT(target, contextRef, ENOMEM);
    CONSTANT(target, contextRef, ENOMSG);
    CONSTANT(target, contextRef, ENOPROTOOPT);
    CONSTANT(target, contextRef, ENOSPC);
    CONSTANT(target, contextRef, ENOSR);
    CONSTANT(target, contextRef, ENOSTR);
    CONSTANT(target, contextRef, ENOSYS);
    CONSTANT(target, contextRef, ENOTCONN);
    CONSTANT(target, contextRef, ENOTDIR);
    CONSTANT(target, contextRef, ENOTEMPTY);
    CONSTANT(target, contextRef, ENOTSOCK);
    CONSTANT(target, contextRef, ENOTSUP);
    CONSTANT(target, contextRef, ENOTTY);
    CONSTANT(target, contextRef, ENXIO);
    CONSTANT(target, contextRef, EOPNOTSUPP);
    CONSTANT(target, contextRef, EOVERFLOW);
    CONSTANT(target, contextRef, EPERM);
    CONSTANT(target, contextRef, EPIPE);
    CONSTANT(target, contextRef, EPROTO);
    CONSTANT(target, contextRef, EPROTONOSUPPORT);
    CONSTANT(target, contextRef, EPROTOTYPE);
    CONSTANT(target, contextRef, ERANGE);
    CONSTANT(target, contextRef, EROFS);
    CONSTANT(target, contextRef, ESPIPE);
    CONSTANT(target, contextRef, ESRCH);
    CONSTANT(target, contextRef, ESTALE);
    CONSTANT(target, contextRef, ETIME);
    CONSTANT(target, contextRef, ETIMEDOUT);
    CONSTANT(target, contextRef, ETXTBSY);
    CONSTANT(target, contextRef, EWOULDBLOCK);
    CONSTANT(target, contextRef, EXDEV);
}

static void define_signal_constants(JSObjectRef target, JSContextRef contextRef) {
    CONSTANT(target, contextRef, SIGHUP);
    CONSTANT(target, contextRef, SIGINT);
    CONSTANT(target, contextRef, SIGQUIT);
    CONSTANT(target, contextRef, SIGILL);
    CONSTANT(target, contextRef, SIGTRAP);
    CONSTANT(target, contextRef, SIGABRT);
    CONSTANT(target, contextRef, SIGIOT);
    CONSTANT(target, contextRef, SIGBUS);
    CONSTANT(target, contextRef, SIGFPE);
    CONSTANT(target, contextRef, SIGKILL);
    CONSTANT(target, contextRef, SIGUSR1);
    CONSTANT(target, contextRef, SIGSEGV);
    CONSTANT(target, contextRef, SIGUSR2);
    CONSTANT(target, contextRef, SIGPIPE);
    CONSTANT(target, contextRef, SIGALRM);
    CONSTANT(target, contextRef, SIGTERM);
    CONSTANT(target, contextRef, SIGCHLD);
#ifdef SIGSTKFLT
    CONSTANT(target, contextRef, SIGSTKFLT);
#endif
    CONSTANT(target, contextRef, SIGCONT);
    CONSTANT(target, contextRef, SIGSTOP);
    CONSTANT(target, contextRef, SIGTSTP);
#ifdef SIGBREAK
    CONSTANT(target, contextRef, SIGBREAK);
#endif
    CONSTANT(target, contextRef, SIGTTIN);
    CONSTANT(target, contextRef, SIGTTOU);
    CONSTANT(target, contextRef, SIGURG);
    CONSTANT(target, contextRef, SIGXCPU);
    CONSTANT(target, contextRef, SIGXFSZ);
    CONSTANT(target, contextRef, SIGVTALRM);
    CONSTANT(target, contextRef, SIGPROF);
    CONSTANT(target, contextRef, SIGWINCH);
    CONSTANT(target, contextRef, SIGIO);
#ifdef SIGPOLL
    CONSTANT(target, contextRef, SIGPOLL);
#endif
#ifdef SIGLOST
    CONSTANT(target, contextRef, SIGLOST);
#endif
#ifdef SIGPWR
    CONSTANT(target, contextRef, SIGPWR);
#endif
    CONSTANT(target, contextRef, SIGSYS);
#ifdef SIGUNUSED
    CONSTANT(target, contextRef, SIGUNUSED);
#endif
}

static void define_system_constants(JSObjectRef target, JSContextRef contextRef) {
    CONSTANT(target, contextRef, O_RDONLY);
    CONSTANT(target, contextRef, O_WRONLY);
    CONSTANT(target, contextRef, O_RDWR);
    CONSTANT(target, contextRef, S_IFMT);
    CONSTANT(target, contextRef, S_IFREG);
    CONSTANT(target, contextRef, S_IFDIR);
    CONSTANT(target, contextRef, S_IFCHR);
    CONSTANT(target, contextRef, S_IFBLK);
    CONSTANT(target, contextRef, S_IFIFO);
    CONSTANT(target, contextRef, S_IFLNK);
    CONSTANT(target, contextRef, S_IFSOCK);
    CONSTANT(target, contextRef, O_CREAT);
    CONSTANT(target, contextRef, O_EXCL);
    CONSTANT(target, contextRef, O_NOCTTY);
    CONSTANT(target, contextRef, O_TRUNC);
    CONSTANT(target, contextRef, O_APPEND);
    CONSTANT(target, contextRef, O_DIRECTORY);
    CONSTANT(target, contextRef, O_EXCL);
    CONSTANT(target, contextRef, O_NOFOLLOW);
    CONSTANT(target, contextRef, O_SYNC);
    CONSTANT(target, contextRef, O_SYMLINK);
#ifdef O_DIRECT
    CONSTANT(target, contextRef, O_DIRECT);
#endif
    CONSTANT(target, contextRef, S_IRWXU);
    CONSTANT(target, contextRef, S_IRUSR);
    CONSTANT(target, contextRef, S_IWUSR);
    CONSTANT(target, contextRef, S_IXUSR);
    CONSTANT(target, contextRef, S_IRWXG);
    CONSTANT(target, contextRef, S_IRGRP);
    CONSTANT(target, contextRef, S_IWGRP);
    CONSTANT(target, contextRef, S_IXGRP);
    CONSTANT(target, contextRef, S_IRWXO);
    CONSTANT(target, contextRef, S_IROTH);
    CONSTANT(target, contextRef, S_IWOTH);
    CONSTANT(target, contextRef, S_IXOTH);
}

@end
