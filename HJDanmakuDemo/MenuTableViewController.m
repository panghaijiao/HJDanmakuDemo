//
//  MenuTableViewController.m
//  HJDanmakuDemo
//
//  Created by haijiao on 2017/7/14.
//  Copyright © 2017年 olinone. All rights reserved.
//

#import "MenuTableViewController.h"
#import "FirstVersionViewController.h"
#import "VideoDemoViewController.h"
#import "LiveDemoViewController.h"

@interface MenuTableViewController ()

@end

@implementation MenuTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"olinone";
    self.tableView.rowHeight = 64.0f;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController *vc = nil;
    switch (indexPath.section) {
        case 0:
        {
            vc = [FirstVersionViewController new];
        }
            break;
        case 1:
        {
            switch (indexPath.row) {
                case 0:
                    vc = [VideoDemoViewController new];
                    break;
                case 1:
                    vc = [LiveDemoViewController new];
                    break;
            }
        }
        default:
            break;
    }
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return section == 0 ? @"1.0": @"2.0";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? 1: 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    switch (indexPath.section) {
        case 0:
        {
            cell.textLabel.text = @"Version 1.0";
        }
            break;
        case 1:
        {
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"VideoMode";
                    break;
                case 1:
                    cell.textLabel.text = @"LiveMode";
                    break;
            }
        }
        default:
            break;
    }
    return cell;
}

@end
