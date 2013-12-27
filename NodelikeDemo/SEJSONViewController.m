//
//  SEJSONViewController.m
//  SEJSONViewController
//
//  Created by Sérgio Estêvão on 04/09/2013.
//  Copyright (c) 2013 Sérgio Estêvão. All rights reserved.
//

#import "SEJSONViewController.h"

@interface SEJSONViewController () {
    id _data;
}

@end

@implementation SEJSONViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setData:(id)data {
    _data = data;
    [self.tableView reloadData];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_data == nil) return 0;
    // Return the number of sections.
    if ([_data isKindOfClass:[NSDictionary class]]){
        return 1;
    }
    
    if ([_data isKindOfClass:[NSArray class]]){
        return [_data count];
    }
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if ([_data isKindOfClass:[NSDictionary class]]){
        return [_data count];
    }
    
    if ([_data isKindOfClass:[NSArray class]]){
        id obj = _data[section];
        if ([obj isKindOfClass:[NSDictionary class]]){
            return [[obj allKeys] count];
        }
        return 1;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    id obj = _data;
    if ([_data isKindOfClass:[NSArray class]]){
        obj = _data[indexPath.section];
    }
    
    if ([obj isKindOfClass:[NSDictionary class]]){
        cell.textLabel.text = [obj allKeys][indexPath.row];
        id subObj = obj[cell.textLabel.text];
        if ([[subObj class] isSubclassOfClass:[NSDictionary class]] ||
            [[subObj class] isSubclassOfClass:[NSArray class]]
            )
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.detailTextLabel.text = @"";
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.detailTextLabel.text = [subObj description];
        }
    } else if ([obj isKindOfClass:[NSArray class]]) {
        cell.textLabel.text = [NSString stringWithFormat:@"%li",(long)indexPath.row];
        cell.detailTextLabel.text = @"";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.textLabel.text = [obj description];
        cell.detailTextLabel.text = @"";
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([[_data class] isSubclassOfClass:[NSArray class]]){
        return [NSString stringWithFormat:@"%li",(long)section];
    }
    
    return @"Attributes";
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    NSString * title = self.title;
    id obj = _data;
    id selectedObjet = nil;
    if ([_data isKindOfClass:[NSArray class]]){
        obj = _data[indexPath.section];
    }
    
    if ([obj isKindOfClass:[NSDictionary class]]){
        NSString * key = [obj allKeys][indexPath.row];
        selectedObjet = obj[key];
        title = key;
    }  else if ([obj isKindOfClass:[NSArray class]]) {
        selectedObjet = obj[indexPath.row];
        title = [NSString stringWithFormat:@"%@-%li",self.title, (long)indexPath.row];
    }
    
    if ( !([selectedObjet isKindOfClass:[NSDictionary class]] || [selectedObjet isKindOfClass:[NSArray class]])) return;
    
    SEJSONViewController *detailViewController = [[SEJSONViewController alloc] initWithStyle:self.tableView.style];
    [detailViewController setData:selectedObjet];
    detailViewController.title = title;
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    
}

@end
