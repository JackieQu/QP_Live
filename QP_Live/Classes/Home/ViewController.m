//
//  ViewController.m
//  QP_Live
//
//  Created by JackieQu on 2017/3/7.
//  Copyright © 2017年 JackieQu. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import "LiveViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(100, 100, 100, 50);
    btn.backgroundColor = [UIColor blueColor];
    [btn addTarget:self action:@selector(enterLiveRoom) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btn];
}

- (void)enterLiveRoom {
    
    /** 判断相机权限 **/
    AVAuthorizationStatus vStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(vStatus == AVAuthorizationStatusRestricted || vStatus == AVAuthorizationStatusDenied){
        
        [[[UIAlertView alloc] initWithTitle:@"无法直播"
                                    message:@"请在“设置-隐私-相机/麦克风”选项中允许冰橙课堂访问你的相机/麦克风,并重新启动app"
                                   delegate:nil
                          cancelButtonTitle:@"确定"
                          otherButtonTitles:nil] show];
    } else {
        /** 判断麦克风权限 **/
        AVAuthorizationStatus aStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
        if(aStatus == AVAuthorizationStatusRestricted || aStatus == AVAuthorizationStatusDenied){
            
            [[[UIAlertView alloc] initWithTitle:@"无法录音"
                                        message:@"请在“设置-隐私-麦克风”选项中允许冰橙课堂访问你的麦克风,并重新启动app"
                                       delegate:nil
                              cancelButtonTitle:@"确定"
                              otherButtonTitles:nil] show];
        } else {
            /** 进入直播 controller **/
            
            // 如需传值操作，写在这之前
            LiveViewController * liveVC = [[LiveViewController alloc] init];
            [self presentViewController:liveVC animated:YES completion:nil];
        }
        /** 判断麦克风权限 **/
    }
}

@end
