//
//  SEJSONViewController.h
//  SEJSONViewController
//
//  Created by Sérgio Estêvão on 04/09/2013.
//  Copyright (c) 2013 Sérgio Estêvão. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 SEJSONViewController allows to browse the content of a JSON object.
 
 @warning SEJSONViewControllers must be used with a navigation controller in order to function properly and to be able to drill down trough the JSON data.
 */
@interface SEJSONViewController : UITableViewController

- (void) setData:(id)data;

@end
