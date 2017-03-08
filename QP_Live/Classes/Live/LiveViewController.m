//
//  LiveViewController.m
//  QP_Live
//
//  Created by JackieQu on 2017/3/8.
//  Copyright © 2017年 JackieQu. All rights reserved.
//

#import "LiveViewController.h"
#import <AFNetworking.h>
#import <PLMediaStreamingKit/PLMediaStreamingKit.h>
#import "KxMenu.h"

@interface LiveViewController ()

// 添加 session 属性
@property (nonatomic, strong) PLMediaStreamingSession * session;
// 推流地址 rtmp_publish_url
@property (nonatomic, strong) NSURL * pushUrl;

@end

@implementation LiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 获取直播流信息
    [self loadData];
    
    // 确认权限
    [self requestAccessForAudio];
    [self requestAccessForVideo];
    
    // 设置监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
}

// 获取 stream，成功后倒计时3秒开始推流直播，失败提示
- (void)loadData {
    
    // MARK: 冰橙课堂接口 id=16 测试
    //    NSString * urlStr = @"http://educloud.haorenao.cn/educloud/qiniulive/begin_live/?id=16";
    
    // MARK: e安接口 streamId=18774389952-7159682 测试
    NSString * urlStr = @"http://test.ean.haorenao.cn:8080/qiniu_live/begin_live/?streamId=18774389952-7159682";
    
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    [manager GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSString * pushStr = [responseObject objectForKey:@"rtmp_publish_url"];
        self.pushUrl = [NSURL URLWithString:pushStr];
        
        NSString * livestream = [responseObject objectForKey:@"livestream"];
        
        NSData * streamData = [livestream dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary * streamJSON = [NSJSONSerialization JSONObjectWithData:streamData options:NSJSONReadingMutableContainers error:nil];
        
        // 创建 stream
        PLStream * stream = [PLStream streamWithJSON:streamJSON];
        
        // 创建视频和音频的采集和编码配置对象
        PLVideoCaptureConfiguration *videoCaptureConfiguration = [PLVideoCaptureConfiguration defaultConfiguration];
        PLAudioCaptureConfiguration *audioCaptureConfiguration = [PLAudioCaptureConfiguration defaultConfiguration];
        PLVideoStreamingConfiguration *videoStreamingConfiguration = [PLVideoStreamingConfiguration defaultConfiguration];
        PLAudioStreamingConfiguration *audioStreamingConfiguration = [PLAudioStreamingConfiguration defaultConfiguration];
        
        // 创建推流 session 对象
        self.session = [[PLMediaStreamingSession alloc] initWithVideoCaptureConfiguration:videoCaptureConfiguration audioCaptureConfiguration:audioCaptureConfiguration videoStreamingConfiguration:videoStreamingConfiguration audioStreamingConfiguration:audioStreamingConfiguration stream:stream];
        
        [self setupUI];
        [self countDown:(3)];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"网络请求失败"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }];
}

// 设置 UI
- (void)setupUI {
    
    // 将预览视图添加为当前视图的子视图
    [self.view addSubview:self.session.previewView];
    
//    // 添加触发按钮
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
//    [button setTitle:@"start" forState:UIControlStateNormal];
//    button.frame = CGRectMake(0, 0, 100, 44);
//    button.center = CGPointMake(CGRectGetMidX([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - 80);
//    [button addTarget:self action:@selector(startLive) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:button];
    
    // 添加其它按钮
    UIButton *otherBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    otherBtn.frame= CGRectMake(self.view.bounds.size.width - 100, self.view.bounds.size.height - 50, 35, 35);
    otherBtn.tintColor = [UIColor clearColor];
    [otherBtn setBackgroundImage:[UIImage imageNamed:@"up_icon"] forState:UIControlStateNormal];
//    [otherBtn setBackgroundImage:[UIImage imageNamed:@"down_icon"] forState:UIControlStateSelected];
    [otherBtn addTarget:self action:@selector(actionOtherBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:otherBtn];
    
    // 添加退出按钮
    UIButton *exitBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    exitBtn.frame = CGRectMake(self.view.bounds.size.width - 50, self.view.bounds.size.height - 50, 35, 35);
    [exitBtn setBackgroundImage:[UIImage imageNamed:@"exit_icon"] forState:UIControlStateNormal];
    [exitBtn addTarget:self action:@selector(actionExitBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:exitBtn];
}

// 3秒倒计时后开始推流
-(void)countDown:(NSUInteger)count{
    
    if(count <= 0){
        [self startLive];
        return;
    }
    
    UILabel* countLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    countLabel.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    countLabel.textColor = [UIColor redColor];
    countLabel.font = [UIFont boldSystemFontOfSize:66];
    countLabel.backgroundColor = [UIColor clearColor];
    countLabel.text = [NSString stringWithFormat:@"%zd",count];
    [self.view addSubview:countLabel];
    
    [UIView animateWithDuration:1
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         countLabel.alpha = 0;
                         countLabel.transform =CGAffineTransformScale(CGAffineTransformIdentity, 0.5, 0.5);
                     }
                     completion:^(BOOL finished) {
                         [countLabel removeFromSuperview];
                         //递归调用，直到计时为零
                         [self countDown:count -1];
                     }
     ];
}

// 开始推流直播
- (void)startLive {
    // 旧版服务器 SDK，返回 hosts 参数，需在 iOS 推流 SDK 中处理生成带权限的推流地址
//    [self.session startStreamingWithFeedback:^(PLStreamStartStateFeedback feedback) {
//        if (feedback == PLStreamStartStateSuccess) {
//            NSLog(@"Streaming started.");
//        }
//        else {
//            NSLog(@"Oops.");
//        }
//    }];
    
    // 新版服务器 SDK，直接提供推流地址 rtmp_publish_url
    [self.session startStreamingWithPushURL:self.pushUrl feedback:^(PLStreamStartStateFeedback feedback) {
        if (feedback == PLStreamStartStateSuccess) {
            NSLog(@"Streaming started.");
        }
        else {
            NSLog(@"Oops.");
        }
    }];
}

#pragma mark -- Button Method
// 实现退出操作
- (void)actionExitBtnPressed:(UIButton *)button {

    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"确定结束直播？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    // 取消退出
    UIAlertAction * action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    // 确认退出
    UIAlertAction * action2 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        [self.session stopStreaming];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alertController addAction:action1];
    [alertController addAction:action2];
    
    //展示alertController
    [self presentViewController:alertController animated:YES completion:nil];
}

// 其它按钮
- (void)actionOtherBtnPressed:(UIButton *)button {
    
    button.selected = !button.selected;
    [self.view addSubview:button];
    
    NSArray *menuItems = @[
                           [KxMenuItem menuItem:@"操作列表"
                                          image:nil
                                         target:nil
                                         action:NULL],
                           
                           [KxMenuItem menuItem:@"闪光灯"
                                          image:[UIImage imageNamed:@"torch_icon"]
                                         target:self
                                         action:@selector(torchBtnPressed:)],
                           
                           [KxMenuItem menuItem:@"翻转"
                                          image:[UIImage imageNamed:@"toggle_icon"]
                                         target:self
                                         action:@selector(toggleBtnPressed:)],
                           
                           [KxMenuItem menuItem:@"静音"
                                          image:[UIImage imageNamed:@"mute_icon"]
                                         target:self
                                         action:@selector(muteBtnPressed:)],
                           ];
    
    KxMenuItem *first = menuItems[0];
    first.foreColor = [UIColor colorWithRed:47/255.0f green:112/255.0f blue:225/255.0f alpha:1.0];
    first.alignment = NSTextAlignmentCenter;
    
    [KxMenu showMenuInView:self.view
                  fromRect:button.frame
                 menuItems:menuItems];
    
}

// 转换摄像头
- (void)toggleBtnPressed:(UIButton *)button {
    [self.session toggleCamera];
}

// 开启闪光灯
- (void)torchBtnPressed:(UIButton *)button {
    self.session.torchOn = !self.session.isTorchOn;
}

// 开启静音
- (void)muteBtnPressed:(UIButton *)button {
    self.session.muted = !self.session.isMuted;
}

#pragma mark -- Public Method
// 请求摄像头权限
- (void)requestAccessForVideo {
    __weak typeof(self) _self = self;
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
            case AVAuthorizationStatusNotDetermined: {
                // 许可对话没有出现，发起授权许可
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    if (granted) {
                        // [_self requestAccessForAudio];
                        [_self startLive];
                    }
                }];
                break;
            }
            case AVAuthorizationStatusAuthorized: {
                // 已经开启授权，可继续
                // [_self requestAccessForAudio];
                [_self startLive];
                break;
            }
            case AVAuthorizationStatusDenied: {
                // 用户明确地拒绝授权，或者相机设备无法访问
                [_self noAccess];
                [_self dismissViewControllerAnimated:YES completion:nil];
                break;
            }
            case AVAuthorizationStatusRestricted: {
                [_self noAccess];
                [_self dismissViewControllerAnimated:YES completion:nil];
                break;
            }
        default:
            break;
    }
}

// 请求麦克风权限
- (void)requestAccessForAudio {
    __weak typeof(self) _self = self;
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (status) {
            case AVAuthorizationStatusNotDetermined: {
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                    
                }];
                break;
            }
            case AVAuthorizationStatusAuthorized: {
                break;
            }
            case AVAuthorizationStatusDenied: {
                [_self noAccess];
                [_self dismissViewControllerAnimated:YES completion:nil];
                break;
            }
            case AVAuthorizationStatusRestricted: {
                [_self noAccess];
                [_self dismissViewControllerAnimated:YES completion:nil];
                break;
            }
        default:
            break;
    }
}

// 无权限提示
- (void)noAccess {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                     message:@"没有相机或麦克风权限，请在设置中开启"
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil, nil];
    [alert show];
}

// 监听进入后台，暂停推流
- (void)applicationWillResignActive:(NSNotification *)notification {
    [self.session stopStreaming];
}

// 监听进入前台，延时3秒后开始推流
- (void)applicationDidBecomeActive:(NSNotification *)notification {
    [self countDown:(3)];
}

@end
