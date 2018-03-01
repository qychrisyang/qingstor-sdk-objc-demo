//
//  ObjectListController.h
//  QingStorSDKObjcDemo
//
//  Created by Chris on 26/02/2018.
//  Copyright © 2018 Yunify. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QingStorSDK-Swift.h"

@interface ObjectListController : UITableViewController
- (void)setBucketModel:(QSBucketModel *)bucketModel;
@end


@interface ObjectTableViewCell: UITableViewCell
@end
