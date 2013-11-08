//
//  PBWebViewController.m
//  Pinbrowser
//
//  Created by Mikael Konutgan on 11/02/2013.
//  Copyright (c) 2013 Mikael Konutgan. All rights reserved.
//

#import "PBWebViewController.h"

@interface PBWebViewController () <UIPopoverControllerDelegate>

@property (strong, nonatomic) UIWebView *webView;

@property (strong, nonatomic) UIBarButtonItem *stopLoadingButton;
@property (strong, nonatomic) UIBarButtonItem *reloadButton;
@property (strong, nonatomic) UIBarButtonItem *backButton;
@property (strong, nonatomic) UIBarButtonItem *forwardButton;

@property (strong, nonatomic) UIPopoverController *activitiyPopoverController;

@property (assign, nonatomic) BOOL toolbarPreviouslyHidden;

@end

@implementation PBWebViewController

- (id)init
{
    self = [super init];
    if (self) {
        _showsNavigationToolbar = YES;
    }
    return self;
}

- (void)load
{
    NSURLRequest *request = [NSURLRequest requestWithURL:self.URL];
    [self.webView loadRequest:request];
    
    if (self.navigationController.toolbarHidden) {
        self.toolbarPreviouslyHidden = YES;
        if (self.showsNavigationToolbar) {
            [self.navigationController setToolbarHidden:NO animated:YES];
        }
    }
}

- (void)clear
{
    [self.webView loadHTMLString:@"" baseURL:nil];
    self.title = @"";
}

#pragma mark - View controller lifecycle

- (void)loadView
{
    self.webView = [[UIWebView alloc] init];
    self.webView.scalesPageToFit = YES;
    self.view = self.webView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupToolBarItems];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.webView.delegate = self;
    if (self.URL) {
        [self load];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.webView stopLoading];
    self.webView.delegate = nil;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    if (self.toolbarPreviouslyHidden && self.showsNavigationToolbar) {
        [self.navigationController setToolbarHidden:YES animated:YES];
    }
}

#pragma mark - Helpers

- (UIImage *)backButtonImage
{
    static UIImage *image;
    
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        CGSize size = CGSizeMake(12.0, 21.0);
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        path.lineWidth = 1.5;
        path.lineCapStyle = kCGLineCapButt;
        path.lineJoinStyle = kCGLineJoinMiter;
        [path moveToPoint:CGPointMake(11.0, 1.0)];
        [path addLineToPoint:CGPointMake(1.0, 11.0)];
        [path addLineToPoint:CGPointMake(11.0, 20.0)];
        [path stroke];
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    
    return image;
}

- (UIImage *)forwardButtonImage
{
    static UIImage *image;
    
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        UIImage *backButtonImage = [self backButtonImage];
        
        CGSize size = backButtonImage.size;
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGFloat x_mid = size.width / 2.0;
        CGFloat y_mid = size.height / 2.0;
        
        CGContextTranslateCTM(context, x_mid, y_mid);
        CGContextRotateCTM(context, M_PI);
        
        [backButtonImage drawAtPoint:CGPointMake(-x_mid, -y_mid)];
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    
    return image;
}

- (void)setupToolBarItems
{
    self.stopLoadingButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                           target:self.webView
                                                                           action:@selector(stopLoading)];
    
    self.reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                      target:self.webView
                                                                      action:@selector(reload)];
    
    self.backButton = [[UIBarButtonItem alloc] initWithImage:[self backButtonImage]
                                                       style:UIBarButtonItemStylePlain
                                                      target:self.webView
                                                      action:@selector(goBack)];
    
    self.forwardButton = [[UIBarButtonItem alloc] initWithImage:[self forwardButtonImage]
                                                          style:UIBarButtonItemStylePlain
                                                         target:self.webView
                                                         action:@selector(goForward)];
    
    self.backButton.enabled = NO;
    self.forwardButton.enabled = NO;
    
    UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                  target:self
                                                                                  action:@selector(action:)];
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                           target:nil
                                                                           action:nil];
    
    UIBarButtonItem *space_ = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                            target:nil
                                                                            action:nil];
    space_.width = 60.0f;
    
    self.toolbarItems = @[self.stopLoadingButton, space, self.backButton, space_, self.forwardButton, space, actionButton];
}

- (void)toggleState
{
    self.backButton.enabled = self.webView.canGoBack;
    self.forwardButton.enabled = self.webView.canGoForward;
    
    NSMutableArray *toolbarItems = [self.toolbarItems mutableCopy];
    if (self.webView.loading) {
        toolbarItems[0] = self.stopLoadingButton;
    } else {
        toolbarItems[0] = self.reloadButton;
    }
    self.toolbarItems = [toolbarItems copy];
}

- (void)finishLoad
{
    [self toggleState];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - Button actions

- (void)action:(id)sender
{
    if (self.activitiyPopoverController.popoverVisible) {
        [self.activitiyPopoverController dismissPopoverAnimated:YES];
        return;
    }
    
    NSArray *activityItems;
    if (self.activityItems) {
        activityItems = [self.activityItems arrayByAddingObject:self.URL];
    } else {
        activityItems = @[self.URL];
    }
    
    UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                                                     applicationActivities:self.applicationActivities];
    if (self.excludedActivityTypes) {
        vc.excludedActivityTypes = self.excludedActivityTypes;
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentViewController:vc animated:YES completion:NULL];
    } else {
        if (!self.activitiyPopoverController) {
            self.activitiyPopoverController = [[UIPopoverController alloc] initWithContentViewController:vc];
        }
        self.activitiyPopoverController.delegate = self;
        [self.activitiyPopoverController presentPopoverFromBarButtonItem:[self.toolbarItems lastObject]
                                                permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

#pragma mark - Web view delegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self toggleState];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self finishLoad];
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.URL = self.webView.request.URL;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self finishLoad];
}

#pragma mark - Popover controller delegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.activitiyPopoverController = nil;
}

@end
