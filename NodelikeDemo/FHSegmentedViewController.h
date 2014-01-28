//
//  KPSegmentedViewController.h
//  KPKuaiPai
//
//  Created by Johnny iDay on 13-12-14.
//  Copyright (c) 2013年 Johnny iDay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FHSegmentedViewController : UIViewController

@property(nonatomic, assign) UIViewController *selectedViewController;
@property(nonatomic, strong) IBOutlet UISegmentedControl *segmentedControl;
@property(nonatomic, assign) NSInteger selectedViewControllerIndex;

- (void)setViewControllers:(NSArray *)viewControllers;
- (void)setViewControllers:(NSArray *)viewControllers titles:(NSArray *)titles;
- (void)setViewControllers:(NSArray *)viewControllers imagesNamed:(NSArray *)imageNames;
- (void)setViewControllers:(NSArray *)viewControllers images:(NSArray *)images;
- (void)pushViewController:(UIViewController *)viewController;
- (void)pushViewController:(UIViewController *)viewController title:(NSString *)title;
- (void)pushViewController:(UIViewController *)viewController imageNamed:(NSString *)imageName;
- (void)pushViewController:(UIViewController *)viewController image:(UIImage *)image;

@end
