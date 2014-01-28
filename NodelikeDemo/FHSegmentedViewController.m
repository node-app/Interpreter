//
//  KPSegmentedViewController.m
//  KPKuaiPai
//
//  Created by Johnny iDay on 13-12-14.
//  Copyright (c) 2013年 Johnny iDay. All rights reserved.
//

#import "FHSegmentedViewController.h"

@interface FHSegmentedViewController ()

@end

@implementation FHSegmentedViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    if (!_segmentedControl) {
        _segmentedControl = [[UISegmentedControl alloc] init];
        _segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
        self.navigationItem.titleView = _segmentedControl;
    } else {
        [_segmentedControl removeAllSegments];
    }
    [_segmentedControl addTarget:self action:@selector(segmentedControlSelected:) forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setViewControllers:(NSArray *)viewControllers titles:(NSArray *)titles
{
    if ([_segmentedControl numberOfSegments] > 0) {
        return;
    }
    for (int i = 0; i < [viewControllers count]; i++) {
        [self pushViewController:viewControllers[i] title:titles[i]];
    }
    [_segmentedControl setSelectedSegmentIndex:0];
    self.selectedViewControllerIndex = 0;
}

- (void)setViewControllers:(NSArray *)viewControllers imagesNamed:(NSArray *)imageNames {
	if ([_segmentedControl numberOfSegments] > 0) {
		return;
	}
	for (int i = 0; i < [viewControllers count]; i++) {
		[self pushViewController:viewControllers[i] imageNamed:imageNames[i]];
	}
	[_segmentedControl setSelectedSegmentIndex:0];
	self.selectedViewControllerIndex = 0;
}

- (void)setViewControllers:(NSArray *)viewControllers images:(NSArray *)images {
	if ([_segmentedControl numberOfSegments] > 0) {
		return;
	}
	for (int i = 0; i < [viewControllers count]; i++) {
		[self pushViewController:viewControllers[i] image:images[i]];
	}
	[_segmentedControl setSelectedSegmentIndex:0];
	self.selectedViewControllerIndex = 0;
}

- (void)setViewControllers:(NSArray *)viewControllers
{
    if ([_segmentedControl numberOfSegments] > 0) {
        return;
    }
    for (int i = 0; i < [viewControllers count]; i++) {
        [self pushViewController:viewControllers[i] title:[viewControllers[i] title]];
    }
    [_segmentedControl setSelectedSegmentIndex:0];
    self.selectedViewControllerIndex = 0;
}

- (void)pushViewController:(UIViewController *)viewController
{
    [self pushViewController:viewController title:viewController.title];
}
- (void)pushViewController:(UIViewController *)viewController title:(NSString *)title
{
    [_segmentedControl insertSegmentWithTitle:title atIndex:_segmentedControl.numberOfSegments animated:NO];
    [self addChildViewController:viewController];
    [_segmentedControl sizeToFit];
}

- (void)pushViewController:(UIViewController *)viewController imageNamed:(NSString *)imageName
{
	[_segmentedControl insertSegmentWithImage:[UIImage imageNamed:imageName] atIndex:_segmentedControl.numberOfSegments animated:NO];
	[self addChildViewController:viewController];
	[_segmentedControl sizeToFit];
}

- (void)pushViewController:(UIViewController *)viewController image:(UIImage *)image {
	[_segmentedControl insertSegmentWithImage:image atIndex:_segmentedControl.numberOfSegments animated:NO];
	[self addChildViewController:viewController];
	[_segmentedControl sizeToFit];
}

- (void)segmentedControlSelected:(id)sender
{
    self.selectedViewControllerIndex = _segmentedControl.selectedSegmentIndex;
}

- (void)setSelectedViewControllerIndex:(NSInteger)index
{
    if (!_selectedViewController) {
        _selectedViewController = self.childViewControllers[index];
        if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0f) {
            CGFloat deltaTop = 20.0f;
            if (self.navigationController && !self.navigationController.navigationBar.translucent) {
                deltaTop = self.navigationController.navigationBar.frame.size.height;
            }
            CGRect frame = self.view.frame;
            [_selectedViewController view].frame = CGRectMake(frame.origin.x, frame.origin.y - deltaTop, frame.size.width, frame.size.height);
			//            [[_selectedViewController view] sizeToFit];
        } else {
            [_selectedViewController view].frame = self.view.frame;
        }
        [self.view addSubview:[_selectedViewController view]];
        [_selectedViewController didMoveToParentViewController:self];
    } else if (index != _selectedViewControllerIndex) {
        if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0f) {
            [self.childViewControllers[index] view].frame = self.view.frame;
        }
        [self transitionFromViewController:_selectedViewController toViewController:self.childViewControllers[index] duration:0.0f options:UIViewAnimationOptionTransitionNone animations:nil completion:^(BOOL finished) {
            _selectedViewController = self.childViewControllers[index];
            _selectedViewControllerIndex = index;
        }];
    }
}

@end
