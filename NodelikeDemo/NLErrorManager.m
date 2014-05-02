//
//  NLErrorManager.m
//  Interpreter
//
//  Created by Marcus Kida on 02.05.14.
//  Copyright (c) 2014 Sam Rijs. All rights reserved.
//

#import "NLErrorManager.h"
#import <SSStackedPageView.h>

#import "NLColor.h"

@interface NLError : NSObject

@property (nonatomic, assign) NLErrorType errorType;
@property (nonatomic, strong) UIColor *errorColor;
@property (nonatomic, strong) NSString *errorMessage;

@end

@implementation NLError

+ (instancetype) newErrorWithType:(NLErrorType)errorType message:(NSString *)message
{
    NLError *error = [NLError new];
    error.errorType = errorType;
    error.errorMessage = message;
    error.errorColor = (errorType == NLErrorTypeGeneralError) ? [NLColor redColor] : [NLColor greenColor];
    return error;
}

@end

@interface NLErrorViewController () <SSStackedViewDelegate>

@property (nonatomic, strong) NLErrorManager *errorManager;

@end

@implementation NLErrorViewController

- (void)awakeFromNib
{
    self.errorManager = [NLErrorManager sharedManager];
    self.title = NSLocalizedString(@"Errors", @"Title for NLErrorViewController");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.stackedPageView.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.stackedPageView layoutSubviews];
}

#pragma mark - SSStackedPageViewControllerDelegate

- (UIView *)stackView:(SSStackedPageView *)stackView pageForIndex:(NSInteger)index
{
    UIView *thisView = [stackView dequeueReusablePage];
    if (!thisView) {
        NLError *error = [self.errorManager errorAtIndex:index];
    
        thisView = [UIView new];
        
        UILabel *label = [[UILabel alloc] initWithFrame:(CGRect){10,10,280,35}];
        label.numberOfLines = 0;
        label.text = error.errorMessage;
        [label sizeToFit];
        [thisView addSubview:label];
        
        thisView.backgroundColor = error.errorColor;
        thisView.layer.borderWidth = 1.0f;
        thisView.layer.cornerRadius = 5.0f;
        thisView.layer.masksToBounds = YES;
    }
    return thisView;
}

- (NSInteger)numberOfPagesForStackView:(SSStackedPageView *)stackView
{
    return [self.errorManager numberOfErrors];
}

- (void)stackView:(SSStackedPageView *)stackView selectedPageAtIndex:(NSInteger) index
{
    NSLog(@"selected page: %i",(int)index);
}

@end

@interface NLErrorManager ()

@property (nonatomic, strong) NSMutableArray *errors;

@end

@implementation NLErrorManager

+ (instancetype)sharedManager
{
    static NLErrorManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        manager.errors = [NSMutableArray new];
    });
    return manager;
}

- (void)dispatchErrorType:(NLErrorType)errorType message:(NSString *)message
{
    NLError *error = [NLError newErrorWithType:errorType message:message];
    [self.errors addObject:error];
}

- (NLError *)errorAtIndex:(NSUInteger)index
{
    return [self.errors objectAtIndex:index];
}

- (NSUInteger)numberOfErrors
{
    return [self.errors count];
}

@end
