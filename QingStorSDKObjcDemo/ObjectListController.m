//
//  ObjectListController.m
//  QingStorSDKObjcDemo
//
//  Created by Chris on 26/02/2018.
//  Copyright © 2018 Yunify. All rights reserved.
//

#import "ObjectListController.h"
#import "AppDelegate.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface ObjectListController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) QSBucketModel *bucketModel;
@property (nonatomic, strong) QSBucket *bucket;
@property (nonatomic, strong) QSListObjectsOutput *objectsOutput;
@property (strong, nonatomic) IBOutlet UIProgressView *progressView;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@end

@implementation ObjectListController

- (void)setBucketModel:(QSBucketModel *)bucketModel {
    _bucketModel = bucketModel;
    
    self.title = bucketModel.name;
    self.bucket = [[AppDelegate globalService] bucketWithBucketName:bucketModel.name zone:bucketModel.location];
}

- (UIActivityIndicatorView *)spinner {
    if (_spinner == nil) {
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
    return _spinner;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(pickImage)];
}

- (void)setupView {
    self.tableView.tableHeaderView = nil;
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
    [self requestObjectList];
}

- (void)requestObjectList {
    QSListObjectsInput *input = [QSListObjectsInput empty];
    [self.bucket listObjectsWithInput:input completion:^(QSListObjectsOutput *output, NSHTTPURLResponse *response, NSError *error) {
        self.objectsOutput = output;
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    }];
}

- (void)pickImage {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Image Source" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    void(^handler)(UIImagePickerControllerSourceType type) = ^(UIImagePickerControllerSourceType type) {
        UIImagePickerController *pickerVC = [[UIImagePickerController alloc] init];
        pickerVC.delegate = self;
        pickerVC.allowsEditing = NO;
        pickerVC.sourceType = type;
        
        [self presentViewController:pickerVC animated:YES completion:nil];
    };
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            handler(UIImagePickerControllerSourceTypeCamera);
        }];
        [alert addAction:cameraAction];
    }
    
    UIAlertAction *albumAction = [UIAlertAction actionWithTitle:@"Choose from Album" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        handler(UIImagePickerControllerSourceTypeSavedPhotosAlbum);
    }];
    [alert addAction:albumAction];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objectsOutput.keys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ObjectCell" forIndexPath:indexPath];
    cell.textLabel.text = self.objectsOutput.keys[indexPath.row].key;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle != UITableViewCellEditingStyleDelete) {
        return;
    }
    
    QSKeyModel *object = self.objectsOutput.keys[indexPath.row];
    QSDeleteObjectInput *input = [[QSDeleteObjectInput alloc] init];
    [self.bucket deleteObjectWithObjectKey:object.key input:input completion:^(QSDeleteObjectOutput *output, NSHTTPURLResponse *response, NSError *error) {
        if (error != nil) { return; }
        
        NSMutableArray *objects = [NSMutableArray arrayWithArray:self.objectsOutput.keys];
        [objects removeObjectAtIndex:indexPath.row];
        self.objectsOutput.keys = objects;
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSString *contentType = CFBridgingRelease(UTTypeCopyPreferredTagWithClass(CFBridgingRetain(info[UIImagePickerControllerMediaType]), kUTTagClassMIMEType));
    
    if (contentType == nil) {
        contentType = @"image/jpeg";
    }

    NSString *pathExtension = @"jpg";
    if ([info[UIImagePickerControllerImageURL] isKindOfClass:[NSURL class]]) {
        pathExtension = ((NSURL *)info[UIImagePickerControllerImageURL]).pathExtension.lowercaseString;
    }
    
    NSString *fileName = [NSString stringWithFormat:@"%ld.%@", (long)[[NSDate date] timeIntervalSince1970], pathExtension];
    if ([info[UIImagePickerControllerOriginalImage] isKindOfClass:[UIImage class]]) {
        UIBarButtonItem *originRightBarButtonItem = self.navigationItem.rightBarButtonItem;
        
        [self.spinner startAnimating];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.spinner];
        self.tableView.tableHeaderView = self.progressView;
        
        NSData *data = UIImageJPEGRepresentation((UIImage *)info[UIImagePickerControllerOriginalImage], .8f);
        QSPutObjectInput *input = [QSPutObjectInput empty];
        input.contentLength = data.length;
        input.contentType = contentType;
        input.bodyInputStream = [[NSInputStream alloc] initWithData:data];
        [self.bucket putObjectWithObjectKey:fileName input:input progress:^(NSProgress *progress) {
            self.progressView.progress = progress.fractionCompleted;
        } completion:^(QSPutObjectOutput *output, NSHTTPURLResponse *response, NSError *error) {
            [self handleRefresh];
            self.navigationItem.rightBarButtonItem = originRightBarButtonItem;
            self.tableView.tableHeaderView = nil;
            self.progressView.progress = 0;
        }];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end


@implementation ObjectTableViewCell
@end
