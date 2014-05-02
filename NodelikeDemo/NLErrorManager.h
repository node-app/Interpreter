//
//  NLErrorManager.h
//  Interpreter
//
//  Created by Marcus Kida on 02.05.14.
//  Copyright (c) 2014 Sam Rijs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSStackedPageView;
@class NLErrorManager;
@class NLError;

typedef NS_ENUM(NSInteger, NLErrorType) {
    NLErrorTypeGeneralError = -1,
    NLErrorTypeSuccess = 0,
};

@interface NLErrorViewController : UIViewController

@property (nonatomic, weak) IBOutlet SSStackedPageView *stackedPageView;

@end

@interface NLErrorManager : NSObject

@property (nonatomic, strong) NLErrorViewController *errorViewController;

+ (instancetype)sharedManager;
- (void)dispatchErrorType:(NLErrorType)errorType message:(NSString *)message;
- (NLError *)errorAtIndex:(NSUInteger)index;
- (NSUInteger)numberOfErrors;

@end
