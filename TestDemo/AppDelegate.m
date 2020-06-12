//
//  AppDelegate.m
//  TestDemo
//
//  Created by ULDD on 2019/12/30.
//  Copyright © 2019 ULDD. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

// 引入 JPush 功能所需头文件
#import "JPUSHService.h"
// iOS10 注册 APNs 所需头文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

#define KNotificationCenter [NSNotificationCenter defaultCenter]

@interface AppDelegate ()<JPUSHRegisterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self pl_configJPush:launchOptions];
    
    ViewController *controller = [[ViewController alloc] init];
    controller.view.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = controller;
    [self.window makeKeyAndVisible];
    return YES;
}



- (void)registerNotification{
    [KNotificationCenter addObserver:self selector:@selector(JPNetworkDidLogin) name:kJPFNetworkDidLoginNotification object:nil];
    [KNotificationCenter addObserver:self selector:@selector(JPNetworkConnect:) name:kJPFNetworkIsConnectingNotification object:nil];
    [KNotificationCenter addObserver:self selector:@selector(JPNetworkDidSetup:) name:kJPFNetworkDidSetupNotification object:nil];
    [KNotificationCenter addObserver:self selector:@selector(JPNetworkDidClose:) name:kJPFNetworkDidCloseNotification object:nil];
    [KNotificationCenter addObserver:self selector:@selector(JPNetworkDidRegister:) name:kJPFNetworkDidRegisterNotification object:nil];
    [KNotificationCenter addObserver:self selector:@selector(JPNetworkLoginFail:) name:kJPFNetworkFailedRegisterNotification object:nil];
    
}


- (void)JPNetworkDidSetup:(NSNotification *)notification{
    NSLog(@"lxt--JPNetworkDidSetup！%@", notification.object);
}
- (void)JPNetworkDidClose:(NSNotification *)notification{
    NSLog(@"lxt--JPNetworkDidClose！%@", notification.object);
}
- (void)JPNetworkConnect:(NSNotification *)notification{
    NSLog(@"lxt--JPNetworkConnect！%@", notification.object);
}
- (void)JPNetworkLoginFail:(NSNotification *)notification{
    NSLog(@"lxt--JPNetworkLoginFail！%@", notification.object);
}

- (void)JPNetworkDidRegister:(NSNotification *)notification{
    NSLog(@"lxt--JPNetworkDidRegister！%@", notification.object);
}

- (void)JPNetworkDidLogin{
    NSLog(@"lxt--激光登录成功！");
}

#pragma Mark JPush
- (void)pl_configJPush:(NSDictionary *)launchOptions{
//    [[PLJPushManager sharedManager] registerNotification];
    [self registerNotification];
    [JPUSHService setDebugMode];
    //Required
    //notice: 3.0.0 及以后版本注册可以这样写，也可以继续用之前的注册方式
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    if (@available(iOS 12.0, *)) {
        entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound|JPAuthorizationOptionProvidesAppNotificationSettings;
    } else {
        // Fallback on earlier versions
        entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    }
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
      // 可以添加自定义 categories
      // NSSet<UNNotificationCategory *> *categories for iOS10 or later
      // NSSet<UIUserNotificationCategory *> *categories for iOS8 and iOS9
    }
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    

}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"lxt--Jpush注册成功 deviceToken = %@", deviceToken);
    /// Required - 注册 DeviceToken
    [JPUSHService registerDeviceToken:deviceToken];

    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
        NSLog(@"lxt--resCode : %d,registrationID: %@",resCode,registrationID);
//        [[PLJPushManager sharedManager] reportRegisterID:registrationID];
    }];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
  //Optional
  NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

#pragma mark- JPUSHRegisterDelegate

// iOS 12 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center openSettingsForNotification:(UNNotification *)notification API_AVAILABLE(ios(10.0)){
//    NSLog(@"lxt--ios 12 userInfo = %@", notification.request.content.userInfo);
    if (@available(iOS 10.0, *)) {
        if (notification && [notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
            //从通知界面直接进入应用
            [self pl_handJPushUserInfo:notification.request.content.userInfo];
        }else{
            //从通知设置界面进入应用
            [self pl_handJPushUserInfo:notification.request.content.userInfo];
        }
    }
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler  API_AVAILABLE(ios(10.0)){
  // Required
  NSDictionary * userInfo = notification.request.content.userInfo;
//    NSLog(@"lxt--ios 10 userInfo = %@", notification.request.content.userInfo);
    if (@available(iOS 10.0, *)) {
        if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
            [JPUSHService handleRemoteNotification:userInfo];
        }
        [self pl_handJPushUserInfo:notification.request.content.userInfo];
        completionHandler(UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有 Badge、Sound、Alert 三种类型可以选择设置
    }
  
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler  API_AVAILABLE(ios(10.0)){
  // Required
  NSDictionary * userInfo = response.notification.request.content.userInfo;
//    NSLog(@"lxt--ios 10 did userInfo = %@", userInfo);
    [self pl_handJPushUserInfo:userInfo];
  if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
    [JPUSHService handleRemoteNotification:userInfo];
  }
  completionHandler();  // 系统要求执行这个方法
}

- (void)jpushNotificationAuthorization:(JPAuthorizationStatus)status withInfo:(NSDictionary *)info {
//    NSLog(@"lxt--jpushNotificationAuthorization = %@", info);
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"lxt--ios 7 userInfo = %@", userInfo);
    [self pl_handJPushUserInfo:userInfo];
  // Required, iOS 7 Support
  [JPUSHService handleRemoteNotification:userInfo];
  completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {

  // Required, For systems with less than or equal to iOS 6
  [JPUSHService handleRemoteNotification:userInfo];
}

- (void)pl_handJPushUserInfo:(NSDictionary *)userInfo{
//    PLJPushUserInfoModel *model = [PLJPushUserInfoModel mj_objectWithKeyValues:userInfo];
//    NSLog(@"lxt--push title = %@", model.aps.alert);
//    if ([PLStringUtil stringIsNotNullOrNil:model.link]) {
//        PLADModel *adModel = [[PLADModel alloc] init];
//        adModel.link = model.link;
//        adModel.linkType = model.linkType;
//        adModel.linkId = model.linkId;
//        [[PLLaunchAdManager shareManager] jumpToControllerWithModel:adModel];
//    }
}



@end
