//
//  BucketListController.m
//  QingStorSDKObjcDemo
//
//  Created by Chris on 26/02/2018.
//  Copyright © 2018 Yunify. All rights reserved.
//

#import "BucketListController.h"
#import "ObjectListController.h"
#import "QingStorSDK-Swift.h"
#import "AppDelegate.h"

@interface BucketListController ()

@property(nonatomic, strong) QSListBucketsOutput *bucketsOutput;

@end

@implementation BucketListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
}

- (void)setupView {
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.tintColor = [UIColor grayColor];
    [refresh addTarget:self action:@selector(handleRefresh) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refresh;
    [self beginRefresh];
}

- (void)beginRefresh {
    if (!self.refreshControl.isRefreshing) {
        [UIView animateWithDuration:0.25 animations: ^{
            self.tableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height - 64);
        } completion:^(BOOL finished) {
            [self.refreshControl beginRefreshing];
            [self.refreshControl sendActionsForControlEvents:UIControlEventValueChanged];
        }];
    }
}

- (void)handleRefresh {
    [self requestBucketList];
    
    // Or can use APISender to send request.
//    [self usingAPISenderToRequestBucketList];
}

- (void)requestBucketList {
    QSListBucketsInput *input = [QSListBucketsInput empty];
    [[AppDelegate globalService] listBucketsWithInput:input completion:^(QSListBucketsOutput *output, NSHTTPURLResponse *response, NSError *error) {
        self.bucketsOutput = output;
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    }];
}

// Using APISender to request bucket list.
- (void)usingAPISenderToRequestBucketList {
    QSListBucketsInput *input = [QSListBucketsInput empty];
    QSAPISender *sender = [[AppDelegate globalService] listBucketsSenderWithInput:input].sender;
    
    // Can use sender to add custom header
    [sender addHeaders:@{@"Custom-Header-Key":@"Custom-Header-Value"}];
    
    // Send api request
    [sender sendListBucketsAPIWithCompletion:^(QSListBucketsOutput *output, NSHTTPURLResponse *response, NSError *error) {
        self.bucketsOutput = output;
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[ObjectListController class]] &&
        [sender isKindOfClass:[QSBucketModel class]] &&
        [segue.identifier isEqualToString:@"ShowObjectList"]) {
        [((ObjectListController *)segue.destinationViewController) setBucketModel:(QSBucketModel *)sender];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.bucketsOutput.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BucketCell" forIndexPath:indexPath];
    cell.textLabel.text = self.bucketsOutput.buckets[indexPath.row].name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"ShowObjectList" sender:self.bucketsOutput.buckets[indexPath.row]];
}

@end


@implementation BucketTableViewCell
@end
