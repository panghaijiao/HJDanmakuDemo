//
//  MenuTableViewController.m
//  HJDanmakuDemo
//
//  Created by haijiao on 2017/7/14.
//  Copyright © 2017年 olinone. All rights reserved.
//

#import "MenuTableViewController.h"
#import "VideoDemoViewController.h"
#import "LiveDemoViewController.h"

@interface MenuTableViewController ()

@end

@implementation MenuTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"olinone";
    self.tableView.rowHeight = 80.0f;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController *vc = nil;
    switch (indexPath.row) {
        case 0:
            vc = [VideoDemoViewController new];
            break;
        case 1:
            vc = [LiveDemoViewController new];
            break;
    }

    [self.navigationController pushViewController:vc animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    vc.title = cell.textLabel.text;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"VideoModel";
            break;
        case 1:
            cell.textLabel.text = @"LiveModel";
            break;
    }
    return cell;
}

@end
