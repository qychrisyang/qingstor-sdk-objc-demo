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
    // Using `APIContext` to initialize QingStor service.
    [self usingAPIContextToInitializeQingStorService];
    
    // Or you can use `Registry` to register QingStor service config.
//    [self usingRegistryToInitializeQingStorService];
    
    // Or you might want to use customized signer to calculate signature string.
//    [self usingCustomizedSignerToCalculateSignatureStringAndInitializeQingStorService];
    
    return YES;
}

// Using `APIContext` to initialize QingStor service.
- (void)usingAPIContextToInitializeQingStorService {
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Config" ofType:@"plist"]];
    QSAPIContext *context = [[QSAPIContext alloc] initWithPlist:url error:nil];
    self.qsService = [[QSQingStor alloc] initWithContext:context];
}

// Using `Registry` to register QingStor service config.
- (void)usingRegistryToInitializeQingStorService {
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Config" ofType:@"plist"]];
    [QSRegistry registerFromPlist:url error:nil];
    self.qsService = [[QSQingStor alloc] init];
}

// Using customized signer to calculate signature string.
- (void)usingCustomizedSignerToCalculateSignatureStringAndInitializeQingStorService {
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Config" ofType:@"plist"]];
    QSAPIContext *context = [[QSAPIContext alloc] initWithPlist:url error:nil];
    QSSignatureTypeModel *signatureType = [QSSignatureTypeModel header];
    QSCustomizedSigner *signer = [[QSCustomizedSigner alloc] initWithSignatureType:signatureType handler:^(QSCustomizedSigner *signer, NSString *plainString, QSRequestBuilder *builder, void (^completion)(QSSignatureResultModel *)) {
        // Setting http date header of used to calculate the signature.
        [builder addHeaders:@{@"Date":@"The date of used to calculate the signature"}];
        
        NSString *signatureString = @"The signature string of you calculated";
        NSString *accessKey = @"The access key of you applied from QingCloud";
        QSSignatureResultModel *result = nil;
        switch (signer.signatureTypeModel.type) {
            case QSSignatureTypeQuery:
                result = [QSSignatureResultModel queryWithSignature:signatureString
                                                          accessKey:accessKey
                                                            expires:@(signer.signatureTypeModel.timeoutSeconds)];
                break;
                
            case QSSignatureTypeHeader:
                result = [QSSignatureResultModel headerWithSignature:signatureString accessKey:accessKey];
                break;
        }
        completion(result);
    }];
    self.qsService = [[QSQingStor alloc] initWithContext:context customizedSigner:signer];
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
