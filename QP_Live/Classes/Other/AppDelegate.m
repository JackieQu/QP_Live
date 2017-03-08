//
//  AppDelegate.m
//  QP_Live
//
//  Created by JackieQu on 2017/3/7.
//  Copyright © 2017年 JackieQu. All rights reserved.
//

#import "AppDelegate.h"
#import <PLMediaStreamingKit/PLMediaStreamingKit.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 初始化 SDK 使用环境
    [PLStreamingEnv initEnv];
    
    return YES;
}

@end
