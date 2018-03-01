//
//  AppDelegate.m
//  QingStorSDKObjcDemo
//
//  Created by Chris on 26/02/2018.
//  Copyright © 2018 Yunify. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@property (nonatomic, strong) QSQingStor *qsService;
@end

@implementation AppDelegate

+ (QSQingStor *)globalService {
    return ((AppDelegate *)[[UIApplication sharedApplication] delegate]).qsService;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Register QingStorSDK
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Config" ofType:@"plist"]];
    [QSRegistry registerFromPlist:url error:nil];
    
    QSSignatureTypeModel *signatureType = [QSSignatureTypeModel header];
    QSQingStorSigner *qingStorSigner = [[QSQingStorSigner alloc] initWithSignatureType:signatureType];
    QSCustomizedSigner *customized = [[QSCustomizedSigner alloc] initWithSignatureType:signatureType handler:^(QSCustomizedSigner *signer, NSString *plainString, QSRequestBuilder *builder, void (^completion)(QSSignatureResultModel *)) {
        switch (signer.signatureTypeModel.type) {
            case QSSignatureTypeQuery:
                completion([qingStorSigner querySignatureStringFrom:builder timeoutSeconds:signer.signatureTypeModel.timeoutSeconds]);
                break;
                
            case QSSignatureTypeHeader:
                completion([qingStorSigner headerSignatureStringFrom:builder]);
                break;
        }
    }];
    self.qsService = [[QSQingStor alloc] initWithCustomizedSigner:customized];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
