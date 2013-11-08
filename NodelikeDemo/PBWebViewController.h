//
//  PBWebViewController.h
//  Pinbrowser
//
//  Created by Mikael Konutgan on 11/02/2013.
//  Copyright (c) 2013 Mikael Konutgan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PBWebViewController : UIViewController <UIWebViewDelegate>

/**
 * The URL that will be loaded by the web view controller.
 * If there is one present when the web view appears, it will be automatically loaded, by calling `load`,
 * Otherwise, you can set a `URL` after the web view has already been loaded and then manually call `load`.
 */
@property (strong, nonatomic) NSURL *URL;

/** The array of data objects on which to perform the activity. */
@property (strong, nonatomic) NSArray *activityItems;

/** An array of UIActivity objects representing the custom services that your application supports. */
@property (strong, nonatomic) NSArray *applicationActivities;

/** The list of services that should not be displayed. */
@property (strong, nonatomic) NSArray *excludedActivityTypes;

/**
 * A Boolean indicating whether the web view controller’s toolbar,
 * which displays a stop/refresh, back, forward and share button, is shown.
 * The default value of this property is `YES`.
 */
@property (assign, nonatomic) BOOL showsNavigationToolbar;

/**
 * Loads the given `URL`. This is called automatically when the when the web view appears if a `URL` exists,
 * otehrwise it can be called manually.
 */
- (void)load;

/**
 * Clears the contents of the web view.
 */
- (void)clear;

@end
